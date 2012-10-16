package eban.validation;

import java.util.List;

import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.xtext.validation.Check;

import com.google.common.collect.Lists;

import eban.webiful.Entity;
import eban.webiful.Feature;
import eban.webiful.Method;
import eban.webiful.Property;
import eban.webiful.WebifulPackage;

public class WebifulJavaValidator extends AbstractWebifulJavaValidator {

	@Check
	public void checkFeatureNameIsUnique(Entity entity) {
		List<String> names = Lists.newArrayList();
		for (Feature f : entity.getFeatures()) {
			String name = null;
			EAttribute attribute = null;
			if (f instanceof Property)
				{
				name = ((Property) f).getName();
				attribute=WebifulPackage.Literals.ENTITY__NAME;
				}
			else if (f instanceof Method)
				{
				name = ((Method) f).getName();
				attribute=WebifulPackage.Literals.METHOD__NAME;
				}

			if (name != null) {
				if (names.contains(name)) {

					error(name + " already declared", f, attribute, 0);
					return;
				}
				names.add(name);
			}
		}

	}
}
