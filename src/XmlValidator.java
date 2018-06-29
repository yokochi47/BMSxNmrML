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
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

import org.apache.xerces.parsers.DOMParser;
import org.xml.sax.ErrorHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXNotRecognizedException;
import org.xml.sax.SAXNotSupportedException;
import org.xml.sax.SAXParseException;

/*
 * XML Schema validation
 * @author yokochi
 */
public class XmlValidator {

	private DOMParser dom_parser = null;
	private Validator err_handler = null;

	public XmlValidator(File xsd_file) {

		dom_parser = new DOMParser();

		try {

			dom_parser.setFeature("http://xml.org/sax/features/validation", true);
			dom_parser.setFeature("http://apache.org/xml/features/validation/schema", true);
			dom_parser.setFeature("http://apache.org/xml/features/validation/schema-full-checking", true);
			dom_parser.setProperty("http://java.sun.com/xml/jaxp/properties/schemaLanguage", "http://www.w3.org/2001/XMLSchema");
			dom_parser.setProperty("http://java.sun.com/xml/jaxp/properties/schemaSource", xsd_file);

		} catch (SAXNotRecognizedException e) {
			e.printStackTrace();
		} catch (SAXNotSupportedException e) {
			e.printStackTrace();
		}

		err_handler = new Validator();

		dom_parser.setErrorHandler(err_handler);

	}

	/*
	 * Execute XML Schema validation
	 * @param xml_file XML file
	 * @param error_dir directory of invalid XML files
	 */
	public void exec(File xml_file, File error_dir) {

		err_handler.init();

		try {

			dom_parser.parse(new InputSource(new FileInputStream(xml_file)));

		} catch (SAXException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		dom_parser.reset();

		if (err_handler.success)
			System.out.println(xml_file.getName() + " is valid.");

		else {

			try {

				File error_file = new File(error_dir, xml_file.getName());
				Files.move(xml_file.toPath(), error_file.toPath(), StandardCopyOption.REPLACE_EXISTING);

			} catch (IOException e) {
				e.printStackTrace();
			}

		}

	}

	/*
	 * Error hander implementation
	 */
	private static class Validator implements ErrorHandler {

		public boolean success = true;

		public void init() {

			success = true;

		}

		@Override
		public void error(SAXParseException e) throws SAXException {

			success = false;

			System.err.println("Error: at " + e.getLineNumber());
			System.err.println(e.getMessage());

		}

		@Override
		public void fatalError(SAXParseException e) throws SAXException {

			success = false;

			System.err.println("Fatal Error: at " + e.getLineNumber());
			System.err.println(e.getMessage());

		}

		@Override
		public void warning(SAXParseException e) throws SAXException {

			success = false;

			System.out.println("Warning: at " + e.getLineNumber());
			System.out.println(e.getMessage());

		}

	}

}
