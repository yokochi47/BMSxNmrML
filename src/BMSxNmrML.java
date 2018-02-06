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

/*
 * Complete nmrML
 * @author yokochi
 */
public class BMSxNmrML {

	public static final String field = "content";
	public static final String document_id = "document_id";
	public static final String rdfs_label = "rdfs:label";

	public static final String bmrbx_namespace_uri = "http://bmrbpub.protein.osaka-u.ac.jp/schema/mmcif_nmr-star.xsd";

	public static final String indent_space = "   ";
	public static final int indent_spaces = 3;

	private static Runtime runtime = Runtime.getRuntime();
	private static final int cpu_num = runtime.availableProcessors();
	private static int max_thrds = cpu_num;

	public static void main(String[] args) {

		String template_dir_name = "nmrml_tmp";
		String production_dir_name = "nmrml_out";
		String obsolete_dir_name= "nmrml_obs";
		String error_dir_name = "nmrml_err";

		String nmrml_xsd_file_name = "schema/nmrML.xsd";
		String chebi_owl_idx_dir_name = "schema/chebi_luceneidx";

		for (int i = 0; i < args.length; i++) {

			if (args[i].equals("--tmp-dir"))
				template_dir_name = args[++i];

			else if (args[i].equals("--out-dir"))
				production_dir_name = args[++i];

			else if (args[i].equals("--obs-dir"))
				obsolete_dir_name = args[++i];

			else if (args[i].equals("--err-dir"))
				error_dir_name = args[++i];

			else if (args[i].equals("--nmrml-xsd"))
				nmrml_xsd_file_name = args[++i];

			else if (args[i].equals("--chebi-owl-idx"))
				chebi_owl_idx_dir_name = args[++i];

			else if (args[i].equals("--max-thrds")) {
				max_thrds = Integer.valueOf(args[++i]);

				if (max_thrds <= 0 || max_thrds > cpu_num) {
					System.err.println("Out of range (max_thrds).");
					System.exit(1);
				}

			}

			else {
				System.out.println("Usage:");
				System.out.println(" --tmp-dir       NMRML_TEMPLATE_DIR (" + template_dir_name + ")");
				System.out.println(" --out-dir       NMRML_PRODUCTION_DIR (" + production_dir_name + ")");
				System.out.println(" --obs-dir       NMRML_OBSOLETE_DIR (" + obsolete_dir_name + ")");
				System.out.println(" --err-dir       NMRML_ERROR_DIR (" + error_dir_name + ")");
				System.out.println(" --nmrml-xsd     NMRML_XSD_FILE (" + nmrml_xsd_file_name + ")");
				System.out.println(" --chebi-owl-idx CHEBI_OWL_INDEX (" + chebi_owl_idx_dir_name + ")");
				System.out.println(" --max-thrds     MAX_THRDS (default is number of available processors)");
				System.exit(1);
			}

		}

		File template_dir = new File(template_dir_name);

		if (!template_dir.isDirectory()) {

			System.err.println(template_dir_name + " is not directory.");
			System.exit(1);

		}

		File production_dir = new File(production_dir_name);

		if (!production_dir.isDirectory()) {

			if (!production_dir.mkdir()) {
				System.err.println("Couldn't create directory '" + production_dir_name + "'.");
				System.exit(1);
			}

		}

		File obsolete_dir = new File(obsolete_dir_name);

		if (!obsolete_dir.isDirectory()) {

			if (!obsolete_dir.mkdir()) {
				System.err.println("Couldn't create directory '" + obsolete_dir_name + "'.");
				System.exit(1);
			}

		}

		File error_dir = new File(error_dir_name);

		if (error_dir.exists()) {

			if (error_dir.isFile())
				error_dir.delete();

			else if (error_dir.isDirectory()) {

				File[] files = error_dir.listFiles();

				for (int i = 0; i < files.length; i++)
					files[i].delete();
			}

		}

		if (!error_dir.isDirectory()) {

			if (!error_dir.mkdir()) {
				System.err.println("Couldn't create directory '" + error_dir_name + "'.");
				System.exit(1);
			}

		}

		File nmrml_xsd_file = new File(nmrml_xsd_file_name);

		if (!nmrml_xsd_file.exists()) {

			System.err.println(nmrml_xsd_file.getPath() + " not found.");
			System.exit(1);

		}

		File chebi_owl_idx_dir = new File(chebi_owl_idx_dir_name);

		if (!chebi_owl_idx_dir.isDirectory()) {

			System.err.println(chebi_owl_idx_dir_name + " is not directory.");
			System.exit(1);

		}

		BMSxNmrMLThrd[] proc_thrd = new BMSxNmrMLThrd[max_thrds];
		Thread[] thrd = new Thread[max_thrds];

		for (int thrd_id = 0; thrd_id < max_thrds; thrd_id++) {

			String thrd_name = "BMSxNmrMLThrd-" + thrd_id;

			proc_thrd[thrd_id] = new BMSxNmrMLThrd(thrd_id, max_thrds, template_dir, production_dir, obsolete_dir, error_dir, nmrml_xsd_file, chebi_owl_idx_dir);
			thrd[thrd_id] = new Thread(proc_thrd[thrd_id], thrd_name);

			thrd[thrd_id].start();

		}

		for (int thrd_id = 0; thrd_id < max_thrds; thrd_id++) {

			try {

				if (thrd[thrd_id] != null)
					thrd[thrd_id].join();

			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}

	}

}
