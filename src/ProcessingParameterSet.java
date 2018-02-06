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

import java.net.URL;

/*
 * Bruker processing parameter file parser
 * @author yokochi
 */
public class ProcessingParameterSet extends AcquisitionParameterSet {

	ProcessingParameterSet(URL acqus_url) {

		super(acqus_url);

	}

	public String getOffset() {
		return values.get("OFFSET");
	}

	public String getSweepWidth() {
		return values.get("SW_p");
	}

	public String getSpctFreq() {
		return values.get("SF");
	}

	public String getPhaceCorrection0() {
		return values.get("PHC0");
	}

	public String getPhaceCorrection1() {
		return values.get("PHC1");
	}

}
