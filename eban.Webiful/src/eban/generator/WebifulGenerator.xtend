package eban.generator

import com.google.inject.Inject
import eban.webiful.Entity
import eban.webiful.Import
import eban.webiful.Method
import eban.webiful.Property
import eban.webiful.MagicPhp
import eban.webiful.Literal
import eban.webiful.Clazz
import eban.webiful.ExpressionsBlock
import eban.webiful.EntryPoint
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider
import eban.webiful.MemberCall
import eban.webiful.Instantiation
import eban.webiful.LocalVarDecl
import eban.webiful.Expression
import eban.webiful.BinaryExpression
import eban.webiful.UnaryExpression
import eban.webiful.Params
import eban.webiful.ParamsCall
import eban.webiful.ParamCall
import eban.webiful.VarCall
import eban.webiful.Routes
import eban.webiful.Route
import eban.webiful.Controller
import eban.webiful.Return
import eban.webiful.StringLiteral
import eban.webiful.Statement
import eban.webiful.If
import eban.webiful.For
import eban.webiful.Param
import java.util.UUID
import java.util.ArrayList
import com.google.common.base.Joiner
import java.util.List
import eban.webiful.MethodOrMagic
import eban.webiful.FeatureOrMagic
import eban.webiful.Feature
import eban.webiful.MagicPhp
import eban.webiful.MagicPhpBlock

class WebifulGenerator implements IGenerator {
	Param runtimeType
	
	@Inject extension IQualifiedNameProvider
	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		var platformString = resource.getURI().toPlatformString(true);
		
		fsa.generateFile(
			platformString.replace("web","php"),
			resource.compileUnit()
		)
	
	}
	
	def compileUnit(Resource resource) 
		'''
		<?php
		«IF resource.allContents.filter(typeof(EntryPoint)).size>0»
		require_once 'routing.php';
		«ENDIF»
		
		
		«FOR imp: resource.allContents.toIterable.filter(typeof(Import))»
		include '«imp.importedNamespace.toString().replace(".","/")+ ".php"»';
		«ENDFOR»
		
		«FOR e: resource.allContents.toIterable.filter(typeof(Entity))»
		«e.compileEntity»
		«ENDFOR»
		«FOR e: resource.allContents.toIterable.filter(typeof(Clazz))»
		«e.compile»
		«ENDFOR»
		
		«FOR e: resource.allContents.toIterable.filter(typeof(Controller))»
		«e.compile»
		«ENDFOR»
		
		«FOR e: resource.allContents.toIterable.filter(typeof(EntryPoint))»
		«e.compile»
		«ENDFOR»
		'''
	def compile(Clazz e) 
		'''class «e.fullyQualifiedName.toString("_")»«IF e.superType != null» extends «e.superType.fullyQualifiedName.toString("_")»«ENDIF» {
		
		function __construct«e.params.compile» {
			«FOR p:e.params.list»
			$this->_«p.name»=$«p.name»;
			«ENDFOR»
	    }
		«FOR p:e.params.list»
			«p.compileConstructorParam»
		«ENDFOR»
		
		
		«FOR f:e.features»
			«f.compile»
		«ENDFOR»
	}
	'''
	


		
		
	def compile(Controller e) 
		'''class «e.fullyQualifiedName.toString("_")»«IF e.superType != null» extends «e.superType.fullyQualifiedName.toString("_")»«ENDIF» {
		«FOR f:e.features»
			«f.compileMM»
		«ENDFOR»
		}
		
	'''
	def compileMM(MethodOrMagic magic) {
		if (magic instanceof Method)
			return (magic as Method).compile
		if (magic instanceof MagicPhpBlock)
			return (magic as MagicPhpBlock).compile
			
	}


	def compile(FeatureOrMagic magic) {
		if (magic instanceof Property)
			return (magic as Property).compile
		if (magic instanceof Method)
			return (magic as Method).compile
		if (magic instanceof MagicPhpBlock)
			return (magic as MagicPhpBlock).compile
	}

	

		
	def compileEntity(Entity e) 
		'''class «e.fullyQualifiedName.toString("_")»«IF e.superType != null» extends «e.superType.fullyQualifiedName.toString("_")»«ENDIF» {
		
		«FOR f:e.features»
			
			«f.compile»
			
		«ENDFOR»
		
	}
	'''
	
	def compile (ExpressionsBlock xps){
		var statements=new ArrayList<CharSequence>()
		for (x:xps.expressions)
			statements.add(x.compile(statements));	
		return Joiner::on(";\n").join(statements)+";\n"
	} 
		
		
		
	def CharSequence compile (Statement x,List<CharSequence> statements){
		if (x instanceof Expression){
			return (x as Expression).compile(statements)
		}
		else if (x instanceof Return){
			return(x as Return).compile(statements)
		}
		else if (x instanceof Literal){
			return(x as Literal).compile(statements)
		}
		else if (x instanceof If){
			return(x as If).compile(statements)
		}
		else if (x instanceof For){
			return(x as For).compile(statements)
		}
		else if (x instanceof LocalVarDecl){
			return(x as LocalVarDecl).compile(statements)
		} 
		return ""
	}
	
	def String compile(For forStatement,List<CharSequence> statements) {
		return '''for («forStatement.condition.compile(statements)» as $«forStatement.forVar.name») 
			«forStatement.doBlock.compile»'''
	}

	def compile(If ifStatement,List<CharSequence> statements) {return "" }

	def CharSequence compile (Expression x,List<CharSequence> statements) {
		if (x instanceof MagicPhp){
			return (x as MagicPhp).compile(statements)
		}
		else if (x instanceof MemberCall){
			return (x as MemberCall).compile(statements)
		}
		else if (x instanceof Literal){
			return(x as Literal).compile(statements)
		}
		else if (x instanceof Instantiation){
			return (x as Instantiation).compile(statements)
		}
		
		else if (x instanceof BinaryExpression){
			return(x as BinaryExpression).compile(statements)
		}
		else if (x instanceof UnaryExpression){
			return(x as UnaryExpression).compile(statements)
		}
		else if (x instanceof VarCall){
			return(x as VarCall).compile(statements)
		}
		return ""
		
		
	}
	
	def compile(Return decl,List<CharSequence> statements) 
		'''return «decl.xp.compile(statements)»'''
	
	
	def compile(LocalVarDecl decl,List<CharSequence> statements) 
	
		'''$«decl.name»=«decl.assignment.compile(statements)»'''
	
	
	def compile(Literal decl,List<CharSequence> statements){ 
	
		if (decl instanceof StringLiteral)
			return '''"«decl.value»"'''
		else
			return decl.value.toString
	}
	
	def compile(BinaryExpression decl,List<CharSequence> statements) 
		'''«decl.leftOperand.compile(statements)»«decl.op»«decl.rightOperand.compile(statements)»'''
	
	def compile(UnaryExpression decl,List<CharSequence> statements) 
		'''«decl.op.toString»«decl.operand.compile(statements)»'''
	
	def compile(Instantiation instantiation,List<CharSequence> statements){
		var varName="tmp_"+UUID::randomUUID().toString.replace("-","")
		statements.add('''$«varName»=new «instantiation.caller.fullyQualifiedName.toString("_")»«instantiation.params.compile(statements)»''')
		return '''$«varName»'''	
	}
		

	def compile(ParamsCall params,List<CharSequence> statements){
		var lst=params.list
		var CharSequence result=""
		
		if (lst.size>0) {
			
				result=lst.get(lst.size-1).compile(statements)
				if (lst.size>1) {
					result='''( «FOR p:0..lst.size-2»«lst.get(p).compile(statements)»,«ENDFOR» «result» )'''
				} else
					result='''( «result» )'''
				
		}
		else	
			result="()"
		return result
	}
	
	def CharSequence compile(ParamCall call,List<CharSequence> statements) {
//		var varName="tmp_"+UUID::randomUUID().toString.replace("-","")
//		statements.add('''$«varName»=«call.xp.compile(statements)»''')
		return call.xp.compile(statements)
	}

	

	
	def compile(Params params){
		var lst=params.list
		var result=""
		
		if (lst.size>0) {
			
				result="$"+lst.get(lst.size-1).name
				if (lst.size>1) {
					result='''( «FOR p:0..lst.size-2»$«lst.get(p).name»,«ENDFOR» «result» )'''
				} else
					result='''( «result» )'''
				
		}
		else	
			result="()"
		return result
	}

	def compile(Method method) {
		
		''' 
			public function «method.name»«method.params.compile» {
				«method.methodBody.compile»
			}
		'''
	}
	
	def compile(EntryPoint ep) ''' 
		$r = new Router();
		«FOR route : ep.entryPointBody.list»
			«route.compile»
		«ENDFOR»
		
		$r->run();
		
		
	'''
	
	def compile(Route route) 
		'''$r->map('«route.url»', array('controller' => '«route.ctrl.fullyQualifiedName.toString("_")»', 'action' => '«route.action.name»','view' => '«route.template»')); 
	'''

	def compile(VarCall call,List<CharSequence> statements){
		return "$"+call.varKind.name
	} 
	def compile(MemberCall call,List<CharSequence> statements) {
//		var varName="tmp_"+UUID::randomUUID().toString.replace("-","")
//		statements.add('''$«varName»=«call.caller.compile(statements)»''')
		return '''«call.caller.compile(statements)»->«IF call.member instanceof Property»«(call.member as Property).name»«ELSE»«(call.member as Method).name»«call.methodsParams.compile(statements)»«ENDIF»'''
	}
	
	def compile(MagicPhp mag,List<CharSequence> statements) 
		'''«mag.instr»'''
	def compile(MagicPhpBlock mag) 
		'''«mag.instr»'''
		
	def compileConstructorParam(Param prop) '''
		private $_«prop.name»;
		function set_«prop.name»($value) {
			$this->_«prop.name»=$value;	
		}
		
		function get_«prop.name»() {
			return $this->_«prop.name»;	
		}
	'''
	def compile(Property prop) '''
		private $_«prop.name»;
		function set_«prop.name»($value) {
			$this->_«prop.name»=$value;	
		}
		
		function get_«prop.name»() {
			return $this->_«prop.name»;	
		}
	'''

}