/*
    BMSxNmrML - nmrML converter for BMRB metabolomics entries
    Copyright 2017-2018 Masashi Yokochi
    
    https://github.com/yokochi47/BMSxNmrML

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */

import java.io.File;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.Deflater;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.codec.binary.Hex;
import org.apache.commons.io.IOUtils;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.MMapDirectory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Text;
import org.xml.sax.SAXException;

import com.sun.org.apache.xml.internal.security.utils.Base64;

/*
 * Processing thread
 * @author yokochi
 */
public class BMSxNmrMLThrd implements Runnable {

	private int thrd_id;
	private int max_thrds;

	private File template_dir;
	private File production_dir;
	private File obsolete_dir;
	private File error_dir;
	private File nmrml_xsd_file;
	private File chebi_owl_idx_dir;

	private byte[] raw_fid_data = null;

	public BMSxNmrMLThrd(int thrd_id, int max_thrds, File template_dir, File production_dir, File obsolete_dir, File error_dir, File nmrml_xsd_file, File chebi_owl_idx_dir) {

		this.thrd_id = thrd_id;
		this.max_thrds = max_thrds;

		this.template_dir = template_dir;
		this.production_dir = production_dir;
		this.obsolete_dir = obsolete_dir;
		this.error_dir = error_dir;
		this.nmrml_xsd_file = nmrml_xsd_file;
		this.chebi_owl_idx_dir = chebi_owl_idx_dir;

	}

	@Override
	public void run() {

		try {

			IndexReader reader = DirectoryReader.open(MMapDirectory.open(chebi_owl_idx_dir.toPath()));
			IndexSearcher chebi_owl_searcher = new IndexSearcher(reader);
			Analyzer analyzer = new StandardAnalyzer();

			QueryParser chebi_owl_parser = new QueryParser(BMSxNmrML.field, analyzer);

			DocumentBuilderFactory doc_builder_fac = DocumentBuilderFactory.newInstance();
			doc_builder_fac.setValidating(false);
			doc_builder_fac.setNamespaceAware(true);
			doc_builder_fac.setFeature("http://apache.org/xml/features/nonvalidating/load-dtd-grammar", false);
			doc_builder_fac.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);
			DocumentBuilder	doc_builder = doc_builder_fac.newDocumentBuilder();

			XmlValidator validator = new XmlValidator(nmrml_xsd_file);

			Pattern nmrml_template_pattern = Pattern.compile("^(bmse[0-9]{6})-exp([0-9]{2}).nmrML$");

			File[] template_entry_dirs = template_dir.listFiles();

			int proc_id = 0;

			for (File template_entry_dir : template_entry_dirs) {

				String entry_id = template_entry_dir.getName();

				if (template_entry_dir.isDirectory() && entry_id.matches("^bmse[0-9]{6}$")) {

					if (proc_id++ % max_thrds != thrd_id)
						continue;

					File production_entry_dir = new File(production_dir, entry_id);

					if (!production_entry_dir.isDirectory()) {

						if (!production_entry_dir.mkdir()) {
							System.err.println("Couldn't create directory '" + production_entry_dir.getPath() + "'.");
							System.exit(1);
						}

					}

					boolean first = true;

					File[] nmrml_templates = template_entry_dir.listFiles();

					for (File nmrml_template : nmrml_templates) {

						Matcher nmrml_template_matcher = nmrml_template_pattern.matcher(nmrml_template.getName());

						if (nmrml_template_matcher.find() && nmrml_template_matcher.group(1).equals(entry_id)) {

							String experiment_code = nmrml_template_matcher.group(2);
							int experiment_id = Integer.valueOf(experiment_code.replaceFirst("^0+", ""));

							if (experiment_id <= 0)
								continue;

							String nmrml_file_name = nmrml_template.getName();

							File nmrml_production = new File(production_entry_dir, nmrml_file_name);

							if (nmrml_production.exists())
								continue;

							File nmrml_obsolete = new File(obsolete_dir, nmrml_file_name);

							if (nmrml_obsolete.exists())
								continue;

							if (first)
								System.out.println(entry_id);

							boolean obsolete = CompleteNmrML(doc_builder, nmrml_template, entry_id, experiment_id, nmrml_production, chebi_owl_parser, chebi_owl_searcher);

							validator.exec(nmrml_production, obsolete ? obsolete_dir : error_dir);

							first = false;

						}

					}

				}

			}

		} catch (ParserConfigurationException | SAXException | IOException | TransformerException e) {
			e.printStackTrace();
			System.exit(1);
		}

	}

	private boolean CompleteNmrML(DocumentBuilder doc_builder, File nmrml_template, String entry_id, int experiment_id, File nmrml_production, QueryParser chebi_owl_parser, IndexSearcher chebi_owl_searcher) throws SAXException, IOException, TransformerException {

		Document document = doc_builder.parse(nmrml_template);

		Node root_node = document.getDocumentElement();

		if (root_node == null) {
			System.err.println("Not found root element in a document.");
			return true;
		}

		RemoveBMRBxNSURI(root_node);

		List<NmrMLSourceFile> source_files = CheckSourceFile(document);

		IdentifySampleSolventType(document, chebi_owl_parser, chebi_owl_searcher);

		AcquisitionParameterSet parameters = null;
		AcquisitionParameterSet parameters_2 = null;
		AcquisitionParameterSet parameters_3 = null;

		ProcessingParameterSet processing = null;
		ProcessingParameterSet processing_2 = null;

		PulseProgramAnnotation pulseprogram = null;
		String entry_url_base = null;

		for (NmrMLSourceFile source_file : source_files) {

			if (source_file.name.equals("acqus"))
				parameters = new AcquisitionParameterSet(source_file.location);

			else if (source_file.name.equals("acqu2s"))
				parameters_2 = new AcquisitionParameterSet(source_file.location);

			else if (source_file.name.equals("acqu3s"))
				parameters_3 = new AcquisitionParameterSet(source_file.location);

			else if (source_file.name.equals("pulseprogram")) {

				pulseprogram = new PulseProgramAnnotation(source_file.location);
				entry_url_base = source_file.location.toString().replaceFirst(source_file.name + "$", "");

			}

			else if (source_file.name.equals("procs"))
				processing = new ProcessingParameterSet(source_file.location);

			else if (source_file.name.equals("proc2s"))
				processing_2 = new ProcessingParameterSet(source_file.location);

		}

		if (parameters != null && parameters.done && pulseprogram != null && pulseprogram.done) {

			ExtractAcquisitionParameterSet(document, parameters, pulseprogram, entry_url_base);
			ExtractDirectDimensionParameterSet(document, parameters, pulseprogram, parameters_2 == null);

			if (parameters_2 != null) {

				ExtractEncodingScheme(document, pulseprogram);
				ExtractIndirectDimensionParameterSet(document, parameters, parameters_2, parameters_3, pulseprogram);

			}

		}

		CheckAcquisitionParameterRefList(document, source_files);
		CheckProcessingParameterRefList(document, source_files);

		if (raw_fid_data != null)
			ExtractFIDData(document);

		if (processing != null) {

			ExtractXAxis(document, processing);

			ExtractPhaseCorrectionParameters(document, processing, true);

			if (processing_2 != null)
				ExtractPhaseCorrectionParameters(document, processing_2, false);

			TrimPhaseCorrectionParameters(document, true);
			TrimPhaseCorrectionParameters(document, false);

		}

		IdentifyChemCompIdentifier(document, chebi_owl_parser, chebi_owl_searcher);

		WriteNmrML(document, nmrml_production);

		document = null;

		for (NmrMLSourceFile file : source_files) {

			if (file.name.equals("fid") || file.name.equals("ser"))
				return file.location == null;

		}

		return true;
	}

	private void RemoveBMRBxNSURI(Node root_node) {

		NamedNodeMap root_attrs = root_node.getAttributes();

		for (int i = 0; i < root_attrs.getLength(); i++) {

			Node root_attr = root_attrs.item(i);

			if (root_attr.getNodeValue().equals(BMSxNmrML.bmrbx_namespace_uri))
				root_attrs.removeNamedItem(root_attr.getNodeName());

		}

	}

	private List<NmrMLSourceFile> CheckSourceFile(Document document) {

		NodeList source_file_list = document.getElementsByTagName("sourceFile");

		List<NmrMLSourceFile> list = new ArrayList<NmrMLSourceFile>();

		boolean valid = true;

		for (int i = 0; i < source_file_list.getLength(); i++) {

			Node source_file = source_file_list.item(i);

			NamedNodeMap source_file_attrs = source_file.getAttributes();

			NmrMLSourceFile file = new NmrMLSourceFile();

			boolean need_sha1 = false;
			URL url = null;

			for (int j = 0; j < source_file_attrs.getLength(); j++) {

				Node source_file_attr = source_file_attrs.item(j);
				String source_file_attr_node_name = source_file_attr.getNodeName();

				if (source_file_attr_node_name.equals("id"))
					file.id = source_file_attr.getNodeValue();

				else if (source_file_attr_node_name.equals("name"))
					file.name = source_file_attr.getNodeValue();

				else if (source_file_attr_node_name.equals("location")) {

					String location = source_file_attr.getNodeValue();

					try {

						url = new URL(location);

						if (!isValidURL(url)) {
							valid = false;
							System.out.println(location + " could not retrieve.");
						}
						else
							file.location = url;

					} catch (MalformedURLException e) {
						System.err.println(location + " is malformed URL.");
						System.exit(1);
					}

				}

				else if (source_file_attr_node_name.equals("sha1")) {

					if (source_file_attr.getNodeValue().equals("NEED_SHA1"))
						need_sha1 = true;

				}

			}

			list.add(file);

			boolean is_fid_data = file.name.equals("fid") || file.name.equals("ser");

			if (need_sha1 && file.location != null) {

				char[] digest = getSHA1(url, is_fid_data);

				if (digest == null) {
					System.err.println("SHA1 digestion of " + url.getPath() + " failed.");
					System.exit(1);
				}

				Node sha1 = source_file_attrs.getNamedItem("sha1");

				sha1.setNodeValue(String.valueOf(digest));

			}

			file = null;

			if (url != null)
				url = null;

		}

		if (!valid) {

			for (NmrMLSourceFile file : list) {

				if (file.location != null)
					continue;

				for (int i = 0; i < source_file_list.getLength(); i++) {

					Node source_file = source_file_list.item(i);

					NamedNodeMap source_file_attrs = source_file.getAttributes();

					for (int j = 0; j < source_file_attrs.getLength(); j++) {

						Node source_file_attr = source_file_attrs.item(j);

						if (source_file_attr.getNodeName().equals("id")) {

							if (!source_file_attr.getNodeValue().equals(file.id))
								continue;

							Node source_file_list_node = source_file.getParentNode();

							Node text_node = source_file.getPreviousSibling();

							if (text_node.getNodeType() == Node.TEXT_NODE)
								source_file_list_node.removeChild(text_node);

							source_file_list_node.removeChild(source_file); // remove sourceFile element

							break;
						}

					}

				}

			}

			list.removeIf(file -> file.location == null);

		}

		return list;
	}

	private boolean isValidURL(URL url) {

		HttpURLConnection.setFollowRedirects(false);

		try {

			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("HEAD");

			return (conn.getResponseCode() == HttpURLConnection.HTTP_OK);

		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		return false;
	}

	private char[] getSHA1(URL url, boolean is_fid_data) {

		HttpURLConnection.setFollowRedirects(false);

		try {

			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("GET");

			if (conn.getResponseCode() != HttpURLConnection.HTTP_OK)
				return null;

			MessageDigest sha1 = MessageDigest.getInstance("SHA-1");

			byte[] digest;

			if (is_fid_data) {

				raw_fid_data = IOUtils.toByteArray(conn.getInputStream());
				digest = sha1.digest(raw_fid_data);

			}

			else
				digest = sha1.digest(IOUtils.toByteArray(conn.getInputStream()));

			return Hex.encodeHex(digest);
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}

		return null;
	}

	private boolean IdentifySampleSolventType(Document document, QueryParser chebi_owl_parser, IndexSearcher chebi_owl_searcher) {

		NodeList solvent_type_list = document.getElementsByTagName("solventType");

		for (int i = 0; i < solvent_type_list.getLength(); i++) {

			Node solvent_type = solvent_type_list.item(i);

			NamedNodeMap solvent_type_attrs = solvent_type.getAttributes();

			boolean need_accession = false;
			String query_code = null;

			for (int j = 0; j < solvent_type_attrs.getLength(); j++) {

				Node solvent_type_attr = solvent_type_attrs.item(j);
				String solvent_type_attr_node_name = solvent_type_attr.getNodeName();

				if (solvent_type_attr_node_name.equals("accession")) {

					if (solvent_type_attr.getNodeValue().equals("NEED_ACCESSION"))
						need_accession = true;

				}

				if (solvent_type_attr_node_name.equals("name"))
					query_code = EscapeQueryCode(solvent_type_attr.getNodeValue());

			}

			if (need_accession && query_code != null) {

				try {

					Query query = chebi_owl_parser.parse(query_code);

					TopDocs results = chebi_owl_searcher.search(query, 1);

					if (results.totalHits == 0) {
						System.err.println("No matching documents for " + query_code + ".");
						return false;
					}

					ScoreDoc[] hits = results.scoreDocs;

					org.apache.lucene.document.Document doc = chebi_owl_searcher.doc(hits[0].doc);

					Node solvent_type_acc = solvent_type_attrs.getNamedItem("accession");

					URL url = new URL(doc.get(BMSxNmrML.document_id));
					String url_path = url.getPath();

					solvent_type_acc.setNodeValue(url_path.substring(url_path.lastIndexOf("/") + 1));

					Node solvent_type_name = solvent_type_attrs.getNamedItem("name");
					solvent_type_name.setNodeValue(doc.get(BMSxNmrML.rdfs_label));

				} catch (ParseException | IOException e) {
					System.err.println("Query code: " + query_code);
					e.printStackTrace();
					System.exit(1);
				}

			}

		}

		return true;
	}

	private void ExtractAcquisitionParameterSet(Document document, AcquisitionParameterSet parameters, PulseProgramAnnotation pulseprogram, String entry_url_base) {

		NodeList source_file_list = document.getElementsByTagName("sourceFile");
		NodeList acq_parameter_set_list = document.getElementsByTagName("acquisitionParameterSet");

		for (int i = 0; i < acq_parameter_set_list.getLength(); i++) {

			Node acq_parameter_set = acq_parameter_set_list.item(i);

			NamedNodeMap acq_parameter_set_attrs = acq_parameter_set.getAttributes();

			for (int j = 0; j < acq_parameter_set_attrs.getLength(); j++) {

				Node acq_parameter_set_attr = acq_parameter_set_attrs.item(j);
				String acq_parameter_set_attr_node_name = acq_parameter_set_attr.getNodeName();

				if (acq_parameter_set_attr_node_name.equals("numberOfSteadyStateScans")) {

					if (acq_parameter_set_attr.getNodeValue().equals("NEED_NUMBER_OF_STEADY_STATE_SCANS"))
						acq_parameter_set_attr.setNodeValue(parameters.getNumberOfSteadyStateScans());

				}

				else if (acq_parameter_set_attr_node_name.equals("numberOfScans")) {

					if (acq_parameter_set_attr.getNodeValue().equals("NEED_NUMBER_OF_SCANS"))
						acq_parameter_set_attr.setNodeValue(parameters.getNumberOfScans());

				}

			}

			for (Node child = acq_parameter_set.getFirstChild(); child != null; child = child.getNextSibling()) {

				String child_node_name = child.getNodeName();

				if (child_node_name.equals("relaxationDelay")) {

					NamedNodeMap relaxation_delay_attrs = child.getAttributes();

					for (int j = 0; j < relaxation_delay_attrs.getLength(); j++) {

						Node relaxation_delay_attr = relaxation_delay_attrs.item(j);

						if (relaxation_delay_attr.getNodeName().equals("value")) {

							if (relaxation_delay_attr.getNodeValue().equals("NEED_RELAXATION_DELAY"))
								relaxation_delay_attr.setNodeValue(parameters.getRelaxationDelay(pulseprogram));

						}

					}

				}

				else if (child_node_name.equals("pulseSequence")) {

					for (Node user_param = child.getFirstChild(); user_param != null; user_param = user_param.getNextSibling()) {

						if (user_param.getNodeName().equals("userParam")) {

							NamedNodeMap user_param_attrs = user_param.getAttributes();

							for (int j = 0; j < user_param_attrs.getLength(); j++) {

								Node user_param_attr = user_param_attrs.item(j);

								if (user_param_attr.getNodeName().equals("value")) {

									if (user_param_attr.getNodeValue().equals("NEED_PULSE_SEQUENCE"))
										user_param_attr.setNodeValue(parameters.getPulseSequence(pulseprogram));

								}

							}

						}

					}

				}

				else if (child_node_name.equals("shapedPulseFile")) {

					NamedNodeMap shaped_pulse_file_attrs = child.getAttributes();

					for (int j = 0; j < shaped_pulse_file_attrs.getLength(); j++) {

						Node shaped_pulse_file_attr = shaped_pulse_file_attrs.item(j);

						if (shaped_pulse_file_attr.getNodeName().equals("ref")) {

							if (shaped_pulse_file_attr.getNodeValue().equals("NEED_SHAPED_PULSE_FILE")) {

								HashSet<String> shaped_file_set = new HashSet<String>();

								for (Map.Entry<String, String> entry : pulseprogram.param_annotations.entrySet()) {

									String value = entry.getValue();

									if (value.contains("decoupling according to sequence defined by")) {

										String shaped_pulse_file_name = value.substring(value.lastIndexOf("by") + 3, value.length()).trim();

										if (!shaped_pulse_file_name.isEmpty()) {

											try {

												URL shaped_pulse_file_url = new URL(entry_url_base + shaped_pulse_file_name);

												if (isValidURL(shaped_pulse_file_url))
													shaped_file_set.add(shaped_pulse_file_name);

											} catch (MalformedURLException e) {
												e.printStackTrace();
											}

										}

									}

								}

								switch (shaped_file_set.size()) {
								case 0:

									Node text_node = child.getPreviousSibling();

									if (text_node.getNodeType() == Node.TEXT_NODE)
										acq_parameter_set.removeChild(text_node);

									acq_parameter_set.removeChild(child); // remove shapedPulseFile element

									break;

								default:

									Iterator<String> shaped_file_iterator = shaped_file_set.iterator();

									int k = 1;

									Node next = child.getNextSibling();

									while (shaped_file_iterator.hasNext()) {

										String shaped_pulse_file_id = "SHAPED_PULSE" + (k == 1 ? "" : k) + "_FILE";

										String shaped_pulse_file_name = shaped_file_iterator.next();

										if (k == 1)
											shaped_pulse_file_attr.setNodeValue(shaped_pulse_file_id);

										else {

											Element shaped_pulse = document.createElement("shapedPulseFile");
											shaped_pulse.setAttribute("ref", shaped_pulse_file_id);

											Text indent = document.createTextNode(BMSxNmrML.indent_space);
											acq_parameter_set.insertBefore(indent, next);

											acq_parameter_set.insertBefore(shaped_pulse, next);

										}

										Node source_file_list_node = source_file_list.item(0).getParentNode();

										Element shaped_pulse_file = document.createElement("sourceFile");
										shaped_pulse_file.setAttribute("id", shaped_pulse_file_id);
										shaped_pulse_file.setAttribute("location", entry_url_base + shaped_pulse_file_name);
										shaped_pulse_file.setAttribute("name", shaped_pulse_file_name);

										Element cvParam = document.createElement("cvParam");
										cvParam.setAttribute("accession", "NMR:1400320");
										cvParam.setAttribute("cvRef", "NMRCV");
										cvParam.setAttribute("name", "Bruker UXNMR/XWIN-NMR format");

										Element cvParam2 = document.createElement("cvParam");
										cvParam2.setAttribute("accession", "NMR:1400121");
										cvParam2.setAttribute("cvRef", "NMRCV");
										cvParam2.setAttribute("name", "shaped pulse file");

										shaped_pulse_file.appendChild(cvParam);
										shaped_pulse_file.appendChild(cvParam2);

										Text indent = document.createTextNode(BMSxNmrML.indent_space);
										source_file_list_node.appendChild(indent);

										source_file_list_node.appendChild(shaped_pulse_file);

										k++;

									}

								}

							}

						}

					}

				}

			}

		}

	}

	private void ExtractDirectDimensionParameterSet(Document document, AcquisitionParameterSet parameters, PulseProgramAnnotation pulseprogram, boolean one_dim) {

		NodeList direct_dim_parameter_set_list = document.getElementsByTagName(one_dim ? "DirectDimensionParameterSet" : "directDimensionParameterSet");

		for (int i = 0; i < direct_dim_parameter_set_list.getLength(); i++) {

			Node direct_dim_parameter_set = direct_dim_parameter_set_list.item(i);

			NamedNodeMap direct_dim_parameter_set_attrs = direct_dim_parameter_set.getAttributes();

			boolean decoupled = pulseprogram.isDecoupled("f2") || pulseprogram.isDecoupled("f3");

			for (int j = 0; j < direct_dim_parameter_set_attrs.getLength(); j++) {

				Node direct_dim_parameter_set_attr = direct_dim_parameter_set_attrs.item(j);
				String direct_dim_parameter_set_attr_node_name = direct_dim_parameter_set_attr.getNodeName();

				if (direct_dim_parameter_set_attr_node_name.equals("decoupled")) {

					if (direct_dim_parameter_set_attr.getNodeValue().equals("NEED_DECOUPLED"))
						direct_dim_parameter_set_attr.setNodeValue(String.valueOf(decoupled));

				}

				else if (direct_dim_parameter_set_attr_node_name.equals("numberOfDataPoints")) {

					if (direct_dim_parameter_set_attr.getNodeValue().equals("NEED_NUMBER_OF_DATA_POINTS"))
						direct_dim_parameter_set_attr.setNodeValue(parameters.getDataPoint());

				}

			}

			for (Node child = direct_dim_parameter_set.getFirstChild(); child != null; child = child.getNextSibling()) {

				String child_node_name = child.getNodeName();

				if (child_node_name.equals("acquisitionNucleus")) {

					String acq_nucleus = parameters.getNucleus1();

					NamedNodeMap acq_nucleus_attrs = child.getAttributes();

					for (int j = 0; j < acq_nucleus_attrs.getLength(); j++) {

						Node acq_nucleus_attr = acq_nucleus_attrs.item(j);
						String acq_nucleus_attr_node_name = acq_nucleus_attr.getNodeName();

						if (acq_nucleus_attr_node_name.equals("accession")) {

							if (acq_nucleus_attr.getNodeValue().equals("NEED_ACCESSION")) {

								switch (acq_nucleus) {
								case "1H":
									acq_nucleus_attr.setNodeValue("NMR:1400151");
									break;
								case "13C":
									acq_nucleus_attr.setNodeValue("NMR:1400154");
									break;
								case "15N":
									acq_nucleus_attr.setNodeValue("NMR:1000213");
									break;
								case "31P":
									acq_nucleus_attr.setNodeValue("NMR:1400158");
									break;
								}

							}

						}

						else if (acq_nucleus_attr_node_name.equals("name")) {

							if (acq_nucleus_attr.getNodeValue().equals("NEED_NAME"))
								acq_nucleus_attr.setNodeValue(acq_nucleus);

						}

					}

				}

				else if (child_node_name.equals("effectiveExcitationField")) {

					NamedNodeMap eff_excitation_field_attrs = child.getAttributes();

					for (int j = 0; j < eff_excitation_field_attrs.getLength(); j++) {

						Node eff_excitation_field_attr = eff_excitation_field_attrs.item(j);

						if (eff_excitation_field_attr.getNodeName().equals("value")) {

							if (eff_excitation_field_attr.getNodeValue().equals("NEED_EFFECTIVE_EXCITATION_FIELD"))
								eff_excitation_field_attr.setNodeValue(parameters.getBField1());

						}

					}

				}

				else if (child_node_name.equals("sweepWidth")) {

					NamedNodeMap sweep_width_attrs = child.getAttributes();

					for (int j = 0; j < sweep_width_attrs.getLength(); j++) {

						Node sweep_width_attr = sweep_width_attrs.item(j);

						if (sweep_width_attr.getNodeName().equals("value")) {

							if (sweep_width_attr.getNodeValue().equals("NEED_SWEEP_WIDTH"))
								sweep_width_attr.setNodeValue(parameters.getSweepWidth());

						}

					}

				}

				else if (child_node_name.equals("pulseWidth")) {

					NamedNodeMap pulse_width_attrs = child.getAttributes();

					for (int j = 0; j < pulse_width_attrs.getLength(); j++) {

						Node pulse_width_attr = pulse_width_attrs.item(j);

						if (pulse_width_attr.getNodeName().equals("value")) {

							if (pulse_width_attr.getNodeValue().equals("NEED_PULSE_WIDTH"))
								pulse_width_attr.setNodeValue(parameters.getPulseWidth(pulseprogram, "f1"));

						}

					}

				}

				else if (child_node_name.equals("irradiationFrequency")) {

					NamedNodeMap irradiation_field_attrs = child.getAttributes();

					for (int j = 0; j < irradiation_field_attrs.getLength(); j++) {

						Node irradiation_field_attr = irradiation_field_attrs.item(j);

						if (irradiation_field_attr.getNodeName().equals("value")) {

							if (irradiation_field_attr.getNodeValue().equals("NEED_IRRADIATION_FREQUENCY"))
								irradiation_field_attr.setNodeValue(parameters.getSpctFreq1());

						}

					}

				}

			}

			for (Node child = direct_dim_parameter_set.getFirstChild(); child != null; child = child.getNextSibling()) {

				if (child.getNodeName().equals("decouplingMethod")) {

					if (!decoupled) {

						Node text_node = child.getPreviousSibling();

						if (text_node.getNodeType() == Node.TEXT_NODE)
							direct_dim_parameter_set.removeChild(text_node);

						direct_dim_parameter_set.removeChild(child); // remove decouplingMethod element

					}

					else {

						if (pulseprogram.isBroadBandDecoupled("f2") || pulseprogram.isBroadBandDecoupled("f3")) {

							Element element = (Element) child;

							element.setAttribute("accession", "NMR:100054");
							element.setAttribute("cvRef", "NMRCV");
							element.setAttribute("name", "broad band decoupling");

						}

						else if (pulseprogram.isNarrowBandDecoupled("f2") || pulseprogram.isNarrowBandDecoupled("f3")) {

							Element element = (Element) child;

							element.setAttribute("accession", "NMR:100056");
							element.setAttribute("cvRef", "NMRCV");
							element.setAttribute("name", "specific decoupling");

						}

						else if (pulseprogram.isOffResonanceDecoupled("f2") || pulseprogram.isOffResonanceDecoupled("f3")) {

							Element element = (Element) child;

							element.setAttribute("accession", "NMR:100055");
							element.setAttribute("cvRef", "NMRCV");
							element.setAttribute("name", "off resonance decoupling");

						}

						else {

							Node text_node = child.getPreviousSibling();

							if (text_node.getNodeType() == Node.TEXT_NODE)
								direct_dim_parameter_set.removeChild(text_node);

							direct_dim_parameter_set.removeChild(child); // remove decouplingMethod element

						}

					}

				}

			}

			for (Node child = direct_dim_parameter_set.getFirstChild(); child != null; child = child.getNextSibling()) {

				if (child.getNodeName().equals("decouplingNucleus")) {

					if (!decoupled) {

						Node text_node = child.getPreviousSibling();

						if (text_node.getNodeType() == Node.TEXT_NODE)
							direct_dim_parameter_set.removeChild(text_node);

						direct_dim_parameter_set.removeChild(child); // remove decouplingMethod element

					}

					else {

						boolean multiple_decoupled = pulseprogram.isDecoupled("f2") && pulseprogram.isDecoupled("f3");

						if (multiple_decoupled) {

							String acq_nucleus = parameters.getNucleus2();

							Element decoupling_nucleus = (Element) child;

							switch (acq_nucleus) {
							case "1H":
								decoupling_nucleus.setAttribute("accession", "NMR:1400151");
								break;
							case "13C":
								decoupling_nucleus.setAttribute("accession", "NMR:1400154");
								break;
							case "15N":
								decoupling_nucleus.setAttribute("accession", "NMR:1400213");
								break;
							case "31P":
								decoupling_nucleus.setAttribute("accession", "NMR:1400158");
								break;
							}

							decoupling_nucleus.setAttribute("cvRef", "NMRCV");
							decoupling_nucleus.setAttribute("name", acq_nucleus);

							acq_nucleus = parameters.getNucleus3();

							Element element = document.createElement("decouplingNucleus");

							element.setAttribute("cvRef", "NMRCV");
							element.setAttribute("name", "broad band decoupling");

							switch (acq_nucleus) {
							case "1H":
								element.setAttribute("accession", "NMR:1400151");
								break;
							case "13C":
								element.setAttribute("accession", "NMR:1400154");
								break;
							case "15N":
								element.setAttribute("accession", "NMR:1400213");
								break;
							case "31P":
								element.setAttribute("accession", "NMR:1400158");
								break;
							}

							element.setAttribute("cvRef", "NMRCV");
							element.setAttribute("name", acq_nucleus);

							Node next = child.getNextSibling();

							Text indent = document.createTextNode(BMSxNmrML.indent_space);
							direct_dim_parameter_set.insertBefore(indent, next);

							direct_dim_parameter_set.insertBefore(element, next);

						}

						else {

							String acq_nucleus = pulseprogram.isDecoupled("f2") ? parameters.getNucleus2() : parameters.getNucleus3();

							Element decoupling_nucleus = (Element) child;

							switch (acq_nucleus) {
							case "1H":
								decoupling_nucleus.setAttribute("accession", "NMR:1400151");
								break;
							case "13C":
								decoupling_nucleus.setAttribute("accession", "NMR:1400154");
								break;
							case "15N":
								decoupling_nucleus.setAttribute("accession", "NMR:1400213");
								break;
							case "31P":
								decoupling_nucleus.setAttribute("accession", "NMR:1400158");
								break;
							}

							decoupling_nucleus.setAttribute("cvRef", "NMRCV");
							decoupling_nucleus.setAttribute("name", acq_nucleus);

						}

					}

				}

			}

		}

	}

	private void ExtractEncodingScheme(Document document, PulseProgramAnnotation pulseprogram) {

		NodeList encoding_scheme_list = document.getElementsByTagName("encodingScheme");

		if (encoding_scheme_list != null) {

			Node encoding_scheme = encoding_scheme_list.item(0);

			NamedNodeMap encoding_scheme_attrs = encoding_scheme.getAttributes();

			for (int j = 0; j < encoding_scheme_attrs.getLength(); j++) {

				Node encoding_scheme_attr = encoding_scheme_attrs.item(j);
				String encoding_scheme_attr_node_name = encoding_scheme_attr.getNodeName();

				String comment = pulseprogram.comment.toLowerCase();

				boolean echo_antiecho = comment.contains("antiecho");
				boolean states_tppi = comment.contains("states") || comment.contains("s-tppi");

				if (encoding_scheme_attr_node_name.equals("accession")) {

					if (encoding_scheme_attr.getNodeValue().equals("NEED_ACCESSION")) {

						if (echo_antiecho)
							encoding_scheme_attr.setNodeValue("NMR:1400057");
						else if (states_tppi)
							encoding_scheme_attr.setNodeValue("NMR:1400053");
						else
							encoding_scheme_attr.setNodeValue("NMR:1400051");

					}

				}

				else if (encoding_scheme_attr_node_name.equals("name")) {

					if (encoding_scheme_attr.getNodeValue().equals("NEED_NAME")) {

						if (echo_antiecho)
							encoding_scheme_attr.setNodeValue("echo anti-echo  coherence selection");
						else if (states_tppi)
							encoding_scheme_attr.setNodeValue("states-time proportional phase incrementation");
						else
							encoding_scheme_attr.setNodeValue("time proportional phase incrementation");

					}

				}

			}

		}

	}

	private void ExtractIndirectDimensionParameterSet(Document document, AcquisitionParameterSet parameters, AcquisitionParameterSet parameters_2, AcquisitionParameterSet parameters_3, PulseProgramAnnotation pulseprogram) {

		NodeList indirect_dim_parameter_set_list = document.getElementsByTagName("indirectDimensionParameterSet");

		for (int i = 0; i < indirect_dim_parameter_set_list.getLength(); i++) {

			Node indirect_dim_parameter_set = indirect_dim_parameter_set_list.item(i);

			NamedNodeMap indirect_dim_parameter_set_attrs = indirect_dim_parameter_set.getAttributes();

			int current_axis_id = i + 2; // 2, 3
			int indirect_axis_id_1 = ((i + 2) % 3) + 1; // 3, 1
			int indirect_axis_id_2 = ((i + 3) % 3) + 1; // 1, 2

			String current_axis_name = "f" + current_axis_id;
			String indirect_axis_name_1 = "f" + indirect_axis_id_1;
			String indirect_axis_name_2 = "f" + indirect_axis_id_2;

			AcquisitionParameterSet current_parameters = (current_axis_id == 2 ? parameters_2 : parameters_3);

			boolean decoupled = pulseprogram.isDecoupled(indirect_axis_name_1) || pulseprogram.isDecoupled(indirect_axis_name_2);

			for (int j = 0; j < indirect_dim_parameter_set_attrs.getLength(); j++) {

				Node indirect_dim_parameter_set_attr = indirect_dim_parameter_set_attrs.item(j);
				String indirect_dim_parameter_set_attr_node_name = indirect_dim_parameter_set_attr.getNodeName();

				if (indirect_dim_parameter_set_attr_node_name.equals("decoupled")) {

					if (indirect_dim_parameter_set_attr.getNodeValue().equals("NEED_DECOUPLED"))
						indirect_dim_parameter_set_attr.setNodeValue(String.valueOf(decoupled));

				}

				else if (indirect_dim_parameter_set_attr_node_name.equals("numberOfDataPoints")) {

					if (indirect_dim_parameter_set_attr.getNodeValue().equals("NEED_NUMBER_OF_DATA_POINTS"))
						indirect_dim_parameter_set_attr.setNodeValue(current_parameters.getDataPoint());

				}

			}

			for (Node child = indirect_dim_parameter_set.getFirstChild(); child != null; child = child.getNextSibling()) {

				String child_node_name = child.getNodeName();

				if (child_node_name.equals("acquisitionNucleus")) {

					String acq_nucleus = current_parameters.getNucleus1();

					NamedNodeMap acq_nucleus_attrs = child.getAttributes();

					for (int j = 0; j < acq_nucleus_attrs.getLength(); j++) {

						Node acq_nucleus_attr = acq_nucleus_attrs.item(j);
						String acq_nucleus_attr_node_name = acq_nucleus_attr.getNodeName();

						if (acq_nucleus_attr_node_name.equals("accession")) {

							if (acq_nucleus_attr.getNodeValue().equals("NEED_ACCESSION")) {

								switch (acq_nucleus) {
								case "1H":
									acq_nucleus_attr.setNodeValue("NMR:1400151");
									break;
								case "13C":
									acq_nucleus_attr.setNodeValue("NMR:1400154");
									break;
								case "15N":
									acq_nucleus_attr.setNodeValue("NMR:1000213");
									break;
								case "31P":
									acq_nucleus_attr.setNodeValue("NMR:1400158");
									break;
								}

							}

						}

						else if (acq_nucleus_attr_node_name.equals("name")) {

							if (acq_nucleus_attr.getNodeValue().equals("NEED_NAME"))
								acq_nucleus_attr.setNodeValue(acq_nucleus);

						}

					}

				}

				else if (child_node_name.equals("effectiveExcitationField")) {

					NamedNodeMap eff_excitation_field_attrs = child.getAttributes();

					for (int j = 0; j < eff_excitation_field_attrs.getLength(); j++) {

						Node eff_excitation_field_attr = eff_excitation_field_attrs.item(j);

						if (eff_excitation_field_attr.getNodeName().equals("value")) {

							if (eff_excitation_field_attr.getNodeValue().equals("NEED_EFFECTIVE_EXCITATION_FIELD"))
								eff_excitation_field_attr.setNodeValue(current_parameters.getBField1());

						}

					}

				}

				else if (child_node_name.equals("sweepWidth")) {

					NamedNodeMap sweep_width_attrs = child.getAttributes();

					for (int j = 0; j < sweep_width_attrs.getLength(); j++) {

						Node sweep_width_attr = sweep_width_attrs.item(j);

						if (sweep_width_attr.getNodeName().equals("value")) {

							if (sweep_width_attr.getNodeValue().equals("NEED_SWEEP_WIDTH"))
								sweep_width_attr.setNodeValue(current_parameters.getSweepWidth());

						}

					}

				}

				else if (child_node_name.equals("pulseWidth")) {

					NamedNodeMap pulse_width_attrs = child.getAttributes();

					for (int j = 0; j < pulse_width_attrs.getLength(); j++) {

						Node pulse_width_attr = pulse_width_attrs.item(j);

						if (pulse_width_attr.getNodeName().equals("value")) {

							if (pulse_width_attr.getNodeValue().equals("NEED_PULSE_WIDTH"))
								pulse_width_attr.setNodeValue(parameters.getPulseWidth(pulseprogram, current_axis_name));

						}

					}

				}

				else if (child_node_name.equals("irradiationFrequency")) {

					NamedNodeMap irradiation_field_attrs = child.getAttributes();

					for (int j = 0; j < irradiation_field_attrs.getLength(); j++) {

						Node irradiation_field_attr = irradiation_field_attrs.item(j);

						if (irradiation_field_attr.getNodeName().equals("value")) {

							if (irradiation_field_attr.getNodeValue().equals("NEED_IRRADIATION_FREQUENCY"))
								irradiation_field_attr.setNodeValue(current_parameters.getSpctFreq1());

						}

					}

				}

			}

			for (Node child = indirect_dim_parameter_set.getFirstChild(); child != null; child = child.getNextSibling()) {

				if (child.getNodeName().equals("decouplingMethod")) {

					if (!decoupled) {

						Node text_node = child.getPreviousSibling();

						if (text_node.getNodeType() == Node.TEXT_NODE)
							indirect_dim_parameter_set.removeChild(text_node);

						indirect_dim_parameter_set.removeChild(child); // remove decouplingMethod element

					}

					else {

						if (pulseprogram.isBroadBandDecoupled(indirect_axis_name_1) || pulseprogram.isBroadBandDecoupled(indirect_axis_name_2)) {

							Element element = (Element) child;

							element.setAttribute("accession", "NMR:100054");
							element.setAttribute("cvRef", "NMRCV");
							element.setAttribute("name", "broad band decoupling");

						}

						else if (pulseprogram.isNarrowBandDecoupled(indirect_axis_name_1) || pulseprogram.isNarrowBandDecoupled(indirect_axis_name_2)) {

							Element element = (Element) child;

							element.setAttribute("accession", "NMR:100056");
							element.setAttribute("cvRef", "NMRCV");
							element.setAttribute("name", "specific decoupling");

						}

						else if (pulseprogram.isOffResonanceDecoupled(indirect_axis_name_1) || pulseprogram.isOffResonanceDecoupled(indirect_axis_name_2)) {

							Element element = (Element) child;

							element.setAttribute("accession", "NMR:100055");
							element.setAttribute("cvRef", "NMRCV");
							element.setAttribute("name", "off resonance decoupling");

						}

						else {

							Node text_node = child.getPreviousSibling();

							if (text_node.getNodeType() == Node.TEXT_NODE)
								indirect_dim_parameter_set.removeChild(text_node);

							indirect_dim_parameter_set.removeChild(child); // remove decouplingMethod element

						}

					}

				}

			}

			for (Node child = indirect_dim_parameter_set.getFirstChild(); child != null; child = child.getNextSibling()) {

				if (child.getNodeName().equals("decouplingNucleus")) {

					if (!decoupled) {

						Node text_node = child.getPreviousSibling();

						if (text_node.getNodeType() == Node.TEXT_NODE)
							indirect_dim_parameter_set.removeChild(text_node);

						indirect_dim_parameter_set.removeChild(child); // remove decouplingMethod element

					}

					else {

						boolean multiple_decoupled = pulseprogram.isDecoupled(indirect_axis_name_1) && pulseprogram.isDecoupled(indirect_axis_name_2);

						if (multiple_decoupled) {

							String acq_nucleus = null;

							switch (indirect_axis_id_1) {
							case 1: acq_nucleus = parameters.getNucleus1();
							break;
							case 2: acq_nucleus = parameters.getNucleus2();
							break;
							case 3: acq_nucleus = parameters.getNucleus3();
							break;
							}

							Element decoupling_nucleus = (Element) child;

							switch (acq_nucleus) {
							case "1H":
								decoupling_nucleus.setAttribute("accession", "NMR:1400151");
								break;
							case "13C":
								decoupling_nucleus.setAttribute("accession", "NMR:1400154");
								break;
							case "15N":
								decoupling_nucleus.setAttribute("accession", "NMR:1400213");
								break;
							case "31P":
								decoupling_nucleus.setAttribute("accession", "NMR:1400158");
								break;
							}

							decoupling_nucleus.setAttribute("cvRef", "NMRCV");
							decoupling_nucleus.setAttribute("name", acq_nucleus);

							switch (indirect_axis_id_2) {
							case 1: acq_nucleus = parameters.getNucleus1();
							break;
							case 2: acq_nucleus = parameters.getNucleus2();
							break;
							case 3: acq_nucleus = parameters.getNucleus3();
							break;
							}

							Element element = document.createElement("decouplingNucleus");

							element.setAttribute("cvRef", "NMRCV");
							element.setAttribute("name", "broad band decoupling");

							switch (acq_nucleus) {
							case "1H":
								element.setAttribute("accession", "NMR:1400151");
								break;
							case "13C":
								element.setAttribute("accession", "NMR:1400154");
								break;
							case "15N":
								element.setAttribute("accession", "NMR:1400213");
								break;
							case "31P":
								element.setAttribute("accession", "NMR:1400158");
								break;
							}

							element.setAttribute("cvRef", "NMRCV");
							element.setAttribute("name", acq_nucleus);

							Node next = child.getNextSibling();

							Text indent = document.createTextNode(BMSxNmrML.indent_space);
							indirect_dim_parameter_set.insertBefore(indent, next);

							indirect_dim_parameter_set.insertBefore(element, next);

						}

						else {

							String acq_nucleus = null;

							if (pulseprogram.isDecoupled(indirect_axis_name_1)) {

								switch (indirect_axis_id_1) {
								case 1: acq_nucleus = parameters.getNucleus1();
								break;
								case 2: acq_nucleus = parameters.getNucleus2();
								break;
								case 3: acq_nucleus = parameters.getNucleus3();
								break;
								}

							}

							else {

								switch (indirect_axis_id_2) {
								case 1: acq_nucleus = parameters.getNucleus1();
								break;
								case 2: acq_nucleus = parameters.getNucleus2();
								break;
								case 3: acq_nucleus = parameters.getNucleus3();
								break;
								}

							}

							Element decoupling_nucleus = (Element) child;

							switch (acq_nucleus) {
							case "1H":
								decoupling_nucleus.setAttribute("accession", "NMR:1400151");
								break;
							case "13C":
								decoupling_nucleus.setAttribute("accession", "NMR:1400154");
								break;
							case "15N":
								decoupling_nucleus.setAttribute("accession", "NMR:1400213");
								break;
							case "31P":
								decoupling_nucleus.setAttribute("accession", "NMR:1400158");
								break;
							}

							decoupling_nucleus.setAttribute("cvRef", "NMRCV");
							decoupling_nucleus.setAttribute("name", acq_nucleus);

						}

					}

				}

			}

		}

	}

	private void CheckAcquisitionParameterRefList(Document document, List<NmrMLSourceFile> source_files) {

		NodeList acq_parameter_ref_list = document.getElementsByTagName("acquisitionParameterRefList");

		for (int i = 0; i < acq_parameter_ref_list.getLength(); i++) {

			Node acq_parameter_ref = acq_parameter_ref_list.item(i);

			for (Node child = acq_parameter_ref.getFirstChild(); child != null; child = child.getNextSibling()) {

				String child_node_name = child.getNodeName();

				if (child_node_name.equals("acquisitionParameterFileRef")) {

					NamedNodeMap acq_parameter_file_ref_attrs = child.getAttributes();

					for (int j = 0; j < acq_parameter_file_ref_attrs.getLength(); j++) {

						Node acq_parameter_file_ref_attr = acq_parameter_file_ref_attrs.item(j);

						if (acq_parameter_file_ref_attr.getNodeName().equals("ref")) {

							String ref = acq_parameter_file_ref_attr.getNodeValue();

							if (!source_files.stream().anyMatch(arg -> arg.id.equals(ref))) {

								Node text_node = child.getPreviousSibling();

								if (text_node.getNodeType() == Node.TEXT_NODE)
									acq_parameter_ref.removeChild(text_node);

								acq_parameter_ref.removeChild(child); // remove acqusitionParameterFileRef element

							}

						}

					}

				}

			}

		}

	}

	private void CheckProcessingParameterRefList(Document document, List<NmrMLSourceFile> source_files) {

		NodeList proc_parameter_ref_list = document.getElementsByTagName("processingParameterFileRefList");

		for (int i = 0; i < proc_parameter_ref_list.getLength(); i++) {

			Node proc_parameter_ref = proc_parameter_ref_list.item(i);

			for (Node child = proc_parameter_ref.getFirstChild(); child != null; child = child.getNextSibling()) {

				String child_node_name = child.getNodeName();

				if (child_node_name.equals("processingParameterFileRef")) {

					NamedNodeMap proc_parameter_file_ref_attrs = child.getAttributes();

					for (int j = 0; j < proc_parameter_file_ref_attrs.getLength(); j++) {

						Node proc_parameter_file_ref_attr = proc_parameter_file_ref_attrs.item(j);

						if (proc_parameter_file_ref_attr.getNodeName().equals("ref")) {

							String ref = proc_parameter_file_ref_attr.getNodeValue();

							if (!source_files.stream().anyMatch(arg -> arg.id.equals(ref))) {

								Node text_node = child.getPreviousSibling();

								if (text_node.getNodeType() == Node.TEXT_NODE)
									proc_parameter_ref.removeChild(text_node);

								proc_parameter_ref.removeChild(child); // remove processingParameterFileRef element

							}

						}

					}

				}

			}

		}

	}

	private void ExtractFIDData(Document document) {

		NodeList fid_data_list = document.getElementsByTagName("fidData");

		Node fid_data = fid_data_list.item(0);

		if (fid_data != null) {

			// Complex128 byte format

			byte[] cnv_fid_data = new byte[raw_fid_data.length * 2];

			for (int i = 0; i < raw_fid_data.length; i += 4) {
				int int_value = Byte2Int(raw_fid_data, i);
				byte[] double_byte = Double2Byte((double) int_value);
				for (int j = 0; j < 8; j++)
					cnv_fid_data[i * 2 + j] = double_byte[j];
			}

			Deflater compresser = new Deflater();
			compresser.setInput(cnv_fid_data);
			compresser.finish();

			cnv_fid_data = null;

			byte[] compressed_fid_data = new byte[raw_fid_data.length * 2];

			int compressed_fid_data_len = compresser.deflate(compressed_fid_data);
			compresser.end();

			String encoded_fid_data = Base64.encode(compressed_fid_data, compressed_fid_data_len);

			NamedNodeMap fid_data_attrs = fid_data.getAttributes();

			for (int j = 0; j < fid_data_attrs.getLength(); j++) {

				Node fid_data_attr = fid_data_attrs.item(j);
				String fid_data_attr_node_name = fid_data_attr.getNodeName();

				if (fid_data_attr_node_name.equals("encodedLength")) {

					if (fid_data_attr.getNodeValue().equals("NEED_ENCODED_LENGTH"))
						fid_data_attr.setNodeValue(String.valueOf(encoded_fid_data.length()));

				}

			}

			if (fid_data.getTextContent().equals("NEED_FID_DATA"))
				fid_data.setTextContent(encoded_fid_data);

			compressed_fid_data = null;

		}

		raw_fid_data = null;

	}

	private byte[] Double2Byte(double value) {
		return ByteBuffer.allocate(8).order(ByteOrder.LITTLE_ENDIAN).putDouble(value).array();
	}

	private int Byte2Int(byte[] data, int pos) {
		return ByteBuffer.wrap(data, pos, 4).getInt();
	}

	private void ExtractXAxis(Document document, ProcessingParameterSet processing) {

		NodeList xaxis_list = document.getElementsByTagName("xAxis");

		Node xaxis = xaxis_list.item(0);

		if (xaxis != null) {

			NamedNodeMap xaxis_attrs = xaxis.getAttributes();

			for (int j = 0; j < xaxis_attrs.getLength(); j++) {

				Node xaxis_attr = xaxis_attrs.item(j);
				String xaxis_attr_node_name = xaxis_attr.getNodeName();

				if (xaxis_attr_node_name.equals("startValue")) {

					if (xaxis_attr.getNodeValue().equals("NEED_START_VALUE"))
						xaxis_attr.setNodeValue(processing.getOffset());

				}

				else if (xaxis_attr_node_name.equals("endValue")) {

					if (xaxis_attr.getNodeValue().equals("NEED_END_VALUE"))
						xaxis_attr.setNodeValue(String.valueOf(Float.valueOf(processing.getOffset()) - Float.valueOf(processing.getSweepWidth()) / Float.valueOf(processing.getSpctFreq())));

				}

			}

		}

	}

	private void ExtractPhaseCorrectionParameters(Document document, ProcessingParameterSet processing, boolean first_dim) {

		NodeList proc_par_list = document.getElementsByTagName(first_dim ? "firstDimensionProcessingParameterSet" : "higherDimensionProcessingParameterSet");

		Node proc_par = proc_par_list.item(0);

		if (proc_par != null) {

			for (Node child = proc_par.getFirstChild(); child != null; child = child.getNextSibling()) {

				String child_node_name = child.getNodeName();

				if (child_node_name.equals("zeroOrderPhaseCorrection")) {

					NamedNodeMap ph0_attrs = child.getAttributes();

					for (int j = 0; j < ph0_attrs.getLength(); j++) {

						Node ph0_attr = ph0_attrs.item(j);
						String ph0_attr_node_name = ph0_attr.getNodeName();

						if (ph0_attr_node_name.equals("value")) {

							if (ph0_attr.getNodeValue().equals("NEED_VALUE"))
								ph0_attr.setNodeValue(processing.getPhaceCorrection0());

						}

					}

				}

				else if (child_node_name.equals("firstOrderPhaseCorrection")) {

					NamedNodeMap ph1_attrs = child.getAttributes();

					for (int j = 0; j < ph1_attrs.getLength(); j++) {

						Node ph1_attr = ph1_attrs.item(j);
						String ph1_attr_node_name = ph1_attr.getNodeName();

						if (ph1_attr_node_name.equals("value")) {

							if (ph1_attr.getNodeValue().equals("NEED_VALUE"))
								ph1_attr.setNodeValue(processing.getPhaceCorrection1());

						}

					}

				}

			}

		}

	}

	private void TrimPhaseCorrectionParameters(Document document, boolean first_dim) {

		NodeList proc_par_list = document.getElementsByTagName(first_dim ? "firstDimensionProcessingParameterSet" : "higherDimensionProcessingParameterSet");

		Node proc_par = proc_par_list.item(0);

		if (proc_par != null) {

			for (Node child = proc_par.getFirstChild(); child != null; child = child.getNextSibling()) {

				if (child.getNodeName().equals("zeroOrderPhaseCorrection")) {

					NamedNodeMap ph0_attrs = child.getAttributes();

					for (int j = 0; j < ph0_attrs.getLength(); j++) {

						Node ph0_attr = ph0_attrs.item(j);
						String ph0_attr_node_name = ph0_attr.getNodeName();

						if (ph0_attr_node_name.equals("value")) {

							if (ph0_attr.getNodeValue().equals("NEED_VALUE")) {

								Node text_node = child.getPreviousSibling();

								if (text_node.getNodeType() == Node.TEXT_NODE)
									proc_par.removeChild(text_node);

								proc_par.removeChild(child); // remove zeroOrderPhaseCorrection element

							}

						}

					}

				}

			}

			for (Node child = proc_par.getFirstChild(); child != null; child = child.getNextSibling()) {

				if (child.getNodeName().equals("firstOrderPhaseCorrection")) {

					NamedNodeMap ph1_attrs = child.getAttributes();

					for (int j = 0; j < ph1_attrs.getLength(); j++) {

						Node ph1_attr = ph1_attrs.item(j);
						String ph1_attr_node_name = ph1_attr.getNodeName();

						if (ph1_attr_node_name.equals("value")) {

							if (ph1_attr.getNodeValue().equals("NEED_VALUE")) {

								Node text_node = child.getPreviousSibling();

								if (text_node.getNodeType() == Node.TEXT_NODE)
									proc_par.removeChild(text_node);

								proc_par.removeChild(child); // remove firstOrderPhaseCorrection element

							}

						}

					}

				}

			}

		}

	}

	private boolean IdentifyChemCompIdentifier(Document document, QueryParser chebi_owl_parser, IndexSearcher chebi_owl_searcher) {

		NodeList identifier_list = document.getElementsByTagName("identifier");

		for (int i = 0; i < identifier_list.getLength(); i++) {

			Node identifier = identifier_list.item(i);

			NamedNodeMap identifier_attrs = identifier.getAttributes();

			boolean need_accession = false;
			String query_code = null;

			for (int j = 0; j < identifier_attrs.getLength(); j++) {

				Node identifier_attr = identifier_attrs.item(j);
				String identifier_attr_node_name = identifier_attr.getNodeName();

				if (identifier_attr_node_name.equals("accession")) {

					if (identifier_attr.getNodeValue().equals("NEED_ACCESSION"))
						need_accession = true;

				}

				if (identifier_attr_node_name.equals("name"))
					query_code = EscapeQueryCode(identifier_attr.getNodeValue());

			}

			if (need_accession && query_code != null) {

				try {

					Query query = chebi_owl_parser.parse(query_code);

					TopDocs results = chebi_owl_searcher.search(query, 1);

					if (results.totalHits == 0) {
						//						System.err.println("No matching documents for " + query_code + ".");
						return false;
					}

					ScoreDoc[] hits = results.scoreDocs;

					org.apache.lucene.document.Document doc = chebi_owl_searcher.doc(hits[0].doc);

					Node identifier_acc = identifier_attrs.getNamedItem("accession");

					URL url = new URL(doc.get(BMSxNmrML.document_id));
					String url_path = url.getPath();

					identifier_acc.setNodeValue(url_path.substring(url_path.lastIndexOf("/") + 1));

					Node identifier_name = identifier_attrs.getNamedItem("name");
					identifier_name.setNodeValue(doc.get(BMSxNmrML.rdfs_label));

				} catch (ParseException | IOException e) {
					System.err.println("Query code: " + query_code);
					e.printStackTrace();
					System.exit(1);
				}

			}

		}

		return true;
	}

	private String EscapeQueryCode(String str) {
		return str.replaceAll("_", "\\-")
				.replaceAll("~", "\\~")
				.replaceAll("-", "\\-")
				.replaceAll("\\+", "\\\\+")
				.replaceAll("\\/", "\\\\/")
				.replaceAll("\\(", "\\\\(").replaceAll("\\)", "\\\\)")
				.replaceAll("\\[", "\\\\[").replaceAll("\\]", "\\\\]");
	}

	private void WriteNmrML(Document document, File output) throws TransformerException {

		TransformerFactory tFactory = TransformerFactory.newInstance();
		Transformer transformer = tFactory.newTransformer();

		transformer.setOutputProperty(OutputKeys.INDENT, "yes");
		transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", String.valueOf(BMSxNmrML.indent_spaces));

		DOMSource source = new DOMSource(document);
		StreamResult result = new StreamResult(output);

		transformer.transform(source, result);

		System.out.println(output.getName() + " done.");

	}

}
