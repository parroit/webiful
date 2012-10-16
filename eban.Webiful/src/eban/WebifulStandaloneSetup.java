
package eban;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class WebifulStandaloneSetup extends WebifulStandaloneSetupGenerated{

	public static void doSetup() {
		new WebifulStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

