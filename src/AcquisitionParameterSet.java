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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/*
 * Bruker acquisition parameter file parser
 * @author yokochi
 */
public class AcquisitionParameterSet {

	HashMap<String, String> values = null;
	HashMap<String, List<String>> arrays = null;

	boolean done = false;

	AcquisitionParameterSet(URL acqus_url) {

		Pattern head_pattern = Pattern.compile("^##([A-Za-z0-9_]+)= (.*)$");
		Pattern value_pattern = Pattern.compile("^##\\$([A-Za-z0-9_]+)= (.*)$");
		Pattern array_pattern = Pattern.compile("^\\(([0-9]+)\\.\\.([0-9]+)\\)$");

		HttpURLConnection.setFollowRedirects(false);

		try {

			HttpURLConnection conn = (HttpURLConnection) acqus_url.openConnection();
			conn.setRequestMethod("GET");

			if (conn.getResponseCode() != HttpURLConnection.HTTP_OK)
				return;

			BufferedReader bufferr = new BufferedReader(new InputStreamReader(conn.getInputStream()));

			String line = bufferr.readLine();

			Matcher matcher = head_pattern.matcher(line);

			if (!matcher.find())
				return;

			values = new HashMap<String, String>();
			arrays = new HashMap<String, List<String>>();

			values.put(matcher.group(1), matcher.group(2));

			boolean header = true;

			while ((line = bufferr.readLine()) != null) {

				if (line.startsWith("$$"))
					continue;

				matcher = header ? head_pattern.matcher(line) : value_pattern.matcher(line);

				if (header && !matcher.find()) {
					matcher = value_pattern.matcher(line);
					header = false;
				}

				if (matcher.find()) {

					String key = matcher.group(1);
					String data = matcher.group(2);

					data = data.trim();

					if (data.startsWith("\"") && data.endsWith("\""))
						data = data.replaceFirst("^\"", "").replaceFirst("\"$", "");

					if (data.startsWith("<")) {

						if (data.endsWith(">"))
							values.put(key, data.substring(1, data.length() - 1));

						else {

							StringBuffer sb = new StringBuffer();
							sb.append(data.substring(1) + "\n");

							while (true) {

								line = bufferr.readLine();

								if (line == null)
									break;

								if (line.startsWith("$$"))
									continue;

								if (line.endsWith(">")) {

									sb.append(line.substring(0, line.length() - 1));
									values.put(key, sb.toString());

									break;
								}

								sb.append(line + "\n");

							}

							sb.setLength(0);
							sb = null;

						}

					}

					else if (data.matches("^\\([0-9]+\\.\\.[0-9]+\\)$")) {

						Matcher array_matcher = array_pattern.matcher(data);

						if (array_matcher.find()) {

							int start_id = Integer.valueOf(array_matcher.group(1));
							int end_id = Integer.valueOf(array_matcher.group(2));

							List<String> array = new ArrayList<String>();

							for (int i = 0; i < start_id; i++)
								array.add("");

							int cur_id = start_id;

							while (true) {

								line = bufferr.readLine();

								if (line == null)
									break;

								if (line.startsWith("$$"))
									continue;

								String[] array_seq = line.split(" ");

								for (int i = 0; i < array_seq.length; i++) {

									if (cur_id++ >= end_id)
										break;

									array.add(array_seq[i]);

								}

								if (cur_id >= end_id)
									break;

							}

							arrays.put(key, array);

						}

					}

					else
						values.put(key, data);

				}

			}

			bufferr.close();

			done = true;

		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	public String getNumberOfSteadyStateScans() {
		return values.get("DS");
	}

	public String getNumberOfScans() {
		return values.get("NS");
	}

	public String getRelaxationDelay(PulseProgramAnnotation pulseprogram) {

		for (Map.Entry<String, String> entry : pulseprogram.param_annotations.entrySet()) {

			if (entry.getValue().contains("relaxation delay")) {

				String key = entry.getKey().toUpperCase();

				if (key.matches("^D[0-9]+$"))
					return arrays.get("D").get(Integer.valueOf(key.substring(1)));

			}

		}

		return arrays.get("D").get(1); // default
	}

	public String getPulseSequence(PulseProgramAnnotation pulseprogram) {

		String name = values.get("PULPROG");

		if (name.equals(pulseprogram.name))
			return name + ": " + pulseprogram.comment;

		return name; // default
	}

	public String getDataPoint() {
		return values.get("TD");
	}

	public String getNucleus1() {
		return values.get("NUC1");
	}

	public String getNucleus2() {
		return values.get("NUC2");
	}

	public String getNucleus3() {
		return values.get("NUC3");
	}

	public String getBField1() {
		return values.get("BF1");
	}

	public String getSpctFreq1() {
		return values.get("SFO1");
	}

	public String getSweepWidth() {
		return values.get("SW_h");
	}

	public String getPulseWidth(PulseProgramAnnotation pulseprogram, String axis) {

		for (Map.Entry<String, String> entry : pulseprogram.param_annotations.entrySet()) {

			String value = entry.getValue();

			if (value.contains(axis) && value.contains("90 degree high power pulse")) {

				String key = entry.getKey().toUpperCase();

				if (key.matches("^P[0-9]+$"))
					return arrays.get("P").get(Integer.valueOf(key.substring(1)));

			}

		}

		return arrays.get("D").get(1); // default
	}

}
