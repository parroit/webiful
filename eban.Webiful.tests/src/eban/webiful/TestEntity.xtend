package eban.webiful

import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.InjectWith
import eban.WebifulInjectorProvider
import org.junit.runner.RunWith
import com.google.inject.Inject
import org.eclipse.xtext.junit4.util.ParseHelper
import org.junit.Test
import static org.junit.Assert.*


@InjectWith(typeof(WebifulInjectorProvider))
@RunWith(typeof(XtextRunner))


class TestEntity{
	@Inject
	ParseHelper<Webiful> parser
 
 	
 
	@Test
	def void parseEntity() {
		val model = parser.parse("
			entity MyEntity {
				parent: MyEntity
			}
		")
		
		val entity = model.elements.head as Entity
		//assertSame(entity, entity.features.head.type)
	}
	
	@Test
	def void parseFun() {
		val model = parser.parse("
			entity MyEntity {
				fun parent(): MyEntity {
					age.age;
				}
			}
		")
		
		val entity = model.elements.head as Entity
		assertEquals("parent", entity.eAllContents.filter(typeof(Method)).head.name)
	}
	

	
	@Test
	def void parseFunSingleInstruction() {
		val model = parser.parse("
			entity MyEntity {
				fun parent(): MyEntity 
					age.age;
				
			}
		")
		
		val entity = model.elements.head as Entity
		assertEquals("parent", entity.eAllContents.filter(typeof(Method)).head.name)
	}
	
}