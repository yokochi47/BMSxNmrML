/*
    BMSxNmrML - nmrML converter for BMRB metabolomics entries
    Copyright 2017-2018 Masashi Yokochi
    
    https://github.com/yokochi47/BMRBxTool

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
 * Bruker pulseprogram file parser
 * @author yokochi
 */
public class PulseProgramAnnotation {

	String name = "";
	String comment = "";

	HashMap<String, String> global_annotations = null;
	HashMap<String, String> param_annotations = null;
	HashMap<String, String> definitions = null;
	HashMap<String, String> substitutions = null;
	List<String> program = null;

	boolean done = false;

	PulseProgramAnnotation(URL pulseprogram_url) {

		Pattern global_anno_pattern = Pattern.compile("^;\\$([A-Za-z0-9_]+)=(.*)$");
		Pattern param_anno_pattern = Pattern.compile("^;([A-Za-z0-9_]+)\\s*:\\s*(.*)$");
		Pattern define_pattern = Pattern.compile("^define (.*) (.*)$");
		Pattern substitution_pattern = Pattern.compile("^\"?([A-Za-z0-9_]+)=(.*)\"?$");

		HttpURLConnection.setFollowRedirects(false);

		try {

			HttpURLConnection conn = (HttpURLConnection) pulseprogram_url.openConnection();
			conn.setRequestMethod("GET");

			if (conn.getResponseCode() != HttpURLConnection.HTTP_OK)
				return;

			BufferedReader bufferr = new BufferedReader(new InputStreamReader(conn.getInputStream()));

			String line = bufferr.readLine();

			if (!line.startsWith("#"))
				return;

			line = bufferr.readLine();

			if (!line.startsWith(";"))
				return;

			global_annotations = new HashMap<String, String>();
			param_annotations = new HashMap<String, String>();
			definitions = new HashMap<String, String>();
			substitutions = new HashMap<String, String>();
			program = new ArrayList<String>();

			name = line.substring(1).trim();

			bufferr.readLine(); // skip avance-version

			StringBuffer sb = new StringBuffer();

			while (true) {

				line = bufferr.readLine();

				if (line.equals(";") || !line.startsWith(";"))
					break;

				if (line.startsWith(";$")) {

					Matcher global_matcher = global_anno_pattern.matcher(line);

					if (global_matcher.find() && !global_matcher.group(2).isEmpty())
						global_annotations.put(global_matcher.group(1), global_matcher.group(2));

				}

				else if (line.startsWith(";")) {

					Matcher param_matcher = param_anno_pattern.matcher(line);

					if (param_matcher.find() && !param_matcher.group(2).isEmpty())
						param_annotations.put(param_matcher.group(1), param_matcher.group(2));

				}

				else if (line.startsWith("define")) {

					Matcher define_matcher = define_pattern.matcher(line);

					if (define_matcher.find())
						definitions.put(define_matcher.group(2), define_matcher.group(1));

				}

				else if (!line.startsWith(" ") && line.contains("=")) {

					Matcher substitution_matcher = substitution_pattern.matcher(line);

					if (substitution_matcher.find() && !substitution_matcher.group(2).isEmpty())
						substitutions.put(substitution_matcher.group(1), substitution_matcher.group(2));

				}

				sb.append(line.substring(1).trim() + " ");

			}

			int len = sb.length();

			if (len > 2)
				comment = sb.substring(0, len - 1);

			sb.setLength(0);
			sb = null;

			while ((line = bufferr.readLine()) != null) {

				if (line.startsWith("#") || line.trim().isEmpty())
					continue;

				if (line.startsWith(";$")) {

					Matcher global_matcher = global_anno_pattern.matcher(line);

					if (global_matcher.find() && !global_matcher.group(2).isEmpty())
						global_annotations.put(global_matcher.group(1), global_matcher.group(2));

				}

				else if (line.startsWith(";")) {

					Matcher param_matcher = param_anno_pattern.matcher(line);

					if (param_matcher.find() && !param_matcher.group(2).isEmpty()) {
						param_annotations.put(param_matcher.group(1), param_matcher.group(2));
					}

				}

				else if (line.startsWith("define")) {

					Matcher define_matcher = define_pattern.matcher(line);

					if (define_matcher.find())
						definitions.put(define_matcher.group(2), define_matcher.group(1));

				}

				else if (!line.startsWith(" ") && line.contains("=")) {

					Matcher substitution_matcher = substitution_pattern.matcher(line);

					if (substitution_matcher.find() && !substitution_matcher.group(2).isEmpty())
						substitutions.put(substitution_matcher.group(1), substitution_matcher.group(2));

				}

				else {

					String trimmed = line.trim().replaceAll("\\s+", " ");

					if (!trimmed.startsWith(";"))
						program.add(trimmed);

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

	public boolean isDecoupled(String axis) {

		for (Map.Entry<String, String> entry : param_annotations.entrySet()) {

			String value = entry.getValue();

			if (value.contains("decoupling according to sequence defined by")) {

				String key = entry.getKey() + ":" + axis;

				for (String line : program) {

					if (line.contains(key))
						return true;

				}

			}

		}

		return false; // default
	}

	public boolean isBroadBandDecoupled(String axis) {

		if (!isDecoupled(axis))
			return false;

		for (Map.Entry<String, String> entry : param_annotations.entrySet()) {

			String value = entry.getValue().toLowerCase();

			if (value.contains(axis) && value.contains("decoupling") && (value.contains("bb") || value.contains("broad")))
				return true;

		}

		return false; // default
	}

	public boolean isNarrowBandDecoupled(String axis) {

		if (!isDecoupled(axis))
			return false;

		for (Map.Entry<String, String> entry : param_annotations.entrySet()) {

			String value = entry.getValue().toLowerCase();

			if (value.contains(axis) && value.contains("decoupling") && (value.contains("nb") || value.contains("narrow") || value.contains("selective") || value.contains("specific")))
				return true;

		}

		return false; // default
	}

	public boolean isOffResonanceDecoupled(String axis) {

		if (!isDecoupled(axis))
			return false;

		for (Map.Entry<String, String> entry : param_annotations.entrySet()) {

			String value = entry.getValue().toLowerCase();

			if (value.contains(axis) && value.contains("decoupling") && value.contains("off") && value.contains("resonance"))
				return true;

		}

		return false; // default
	}

}
