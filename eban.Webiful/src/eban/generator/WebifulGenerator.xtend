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
import eban.webiful.Instantiation
import eban.webiful.LocalVarDecl
import eban.webiful.Expression
import eban.webiful.BinaryExpression
import eban.webiful.UnaryExpression
import eban.webiful.Params
import eban.webiful.ParamsCall
import eban.webiful.ParamCall
import eban.webiful.VarCall
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
import eban.webiful.MagicPhpBlock
import eban.webiful.TerminalExpr
import eban.webiful.ContinuationExpr
import org.eclipse.emf.common.util.EList
import eban.webiful.PropertyCallExpr
import eban.webiful.MethodCallExpr

import eban.webiful.IntegerLiteral
import eban.webiful.DecimalLiteral
import eban.webiful.HashLiteral
import eban.webiful.StrKeyType
import eban.webiful.IdKeyType
import eban.webiful.EntityFeatureOrMagic
import eban.webiful.EntityProperty
import eban.webiful.IndexGetExpr
import eban.webiful.AssignStatement
import eban.webiful.AssignStatement
import eban.webiful.This

class WebifulGenerator implements IGenerator {
	//Param runtimeType
	
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
		�IF resource.allContents.filter(typeof(EntryPoint)).size>0�
		require_once 'routing.php';
		�ENDIF�
		
		�FOR php: resource.contents.get(0).eContents.filter(typeof(MagicPhpBlock))�
			�php.compile�
		�ENDFOR�
		
		�FOR imp: resource.allContents.toIterable.filter(typeof(Import))�
		require_once '�imp.importedNamespace.toString().replace(".","/")+ ".php"�';
		�ENDFOR�
		
		�FOR e: resource.allContents.toIterable.filter(typeof(Entity))�
		�e.compileEntity�
		�ENDFOR�
		�FOR e: resource.allContents.toIterable.filter(typeof(Clazz))�
		�e.compile�
		�ENDFOR�
		
		�FOR e: resource.allContents.toIterable.filter(typeof(Controller))�
		�e.compile�
		�ENDFOR�
		
		�FOR e: resource.allContents.toIterable.filter(typeof(EntryPoint))�
		�e.compile�
		�ENDFOR�
		'''
	
	def compile(Clazz e) 
		'''class �e.fullyQualifiedName.toString("_")��IF e.superType != null� extends �e.superType.fullyQualifiedName.toString("_")��ENDIF� {
		�IF e.params!=null || e.features.filter(typeof(ExpressionsBlock)).size>0�
			function __construct�IF e.params!=null��e.params.compile��ELSE�()�ENDIF� {
				�IF e.params!=null�
					�FOR p:e.params.list�
					$this->_�p.name�=$�p.name�;
					�ENDFOR�
				�ENDIF�	
				�FOR block:e.features.filter(typeof(ExpressionsBlock))�
					�block.compile()�
				�ENDFOR�
			}
			�IF e.params!=null�
			�FOR p:e.params.list�
				�p.compileConstructorParam�
			�ENDFOR�
			�ENDIF�
		�ENDIF�
		
		�FOR f:e.features�
			�f.compile�
		�ENDFOR�
	}
	'''
	


		
		
	def compile(Controller e) 
		'''class �e.fullyQualifiedName.toString("_")��IF e.superType != null� extends �e.superType.fullyQualifiedName.toString("_")��ENDIF� {
		�FOR f:e.features�
			�f.compileMM�
		�ENDFOR�
		}
		
	'''
	def compileMM(MethodOrMagic magic) {
		if (magic instanceof Method)
			return (magic as Method).compile
		if (magic instanceof MagicPhpBlock)
			return (magic as MagicPhpBlock).compile
			
	}

	def compile(EntityFeatureOrMagic magic) {
		if (magic instanceof EntityProperty)
			return (magic as EntityProperty).compile
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
		'''
		/**
		 * @Entity @Table(name="users")
		 **/
		class �e.fullyQualifiedName.toString("_")��IF e.superType != null� extends �e.superType.fullyQualifiedName.toString("_")��ENDIF� {
		
		�FOR f:e.features�
			
			�f.compile�
			
		�ENDFOR�
		public function __get($name)
	    {
			�FOR f:e.features.filter(typeof(EntityProperty))�
			if ('�f.propertyName�' == $name) {
				return $this->get_�f.propertyName�();
			}	
			�ENDFOR�
	        
	    }
	
		public function __isset($name)
	    {
			�FOR f:e.features.filter(typeof(EntityProperty))�
			if ('�f.propertyName�' == $name) {
				return true;
			}	
			�ENDFOR�
	        return false;
	    }
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
		else if (x instanceof AssignStatement){
			return(x as AssignStatement).compile(statements)
		} 
		return ""
	}
	
	
	
	def String compile(For forStatement,List<CharSequence> statements) {
		return '''for (�forStatement.condition.compile(statements)� as $�forStatement.forVar.name�) 
			�forStatement.doBlock.compile�'''
	}

	def compile(If ifStatement,List<CharSequence> statements) {
		return '''if (�ifStatement.condition.compile(statements)�) {
					�ifStatement.then.compile()�
				} else {
					�ifStatement.elseBlock.compile()�
				}
				'''
	}

	def CharSequence compile (Expression x,List<CharSequence> statements) {
		return x.terms.compile(statements) + x.continuation.compile(statements)
		
		
		
	}
	def compile(EList<ContinuationExpr> list,List<CharSequence> statements) { 
		var subStatements=new ArrayList<CharSequence>()
		for (x:list){
				
		
			if (x instanceof PropertyCallExpr){
				subStatements.add((x as PropertyCallExpr).compile(statements))
			}
			else if (x instanceof MethodCallExpr){
				subStatements.add((x as MethodCallExpr).compile(statements))
			}
			else if (x instanceof BinaryExpression){
				subStatements.add((x as BinaryExpression).compile(statements))
			}
			else if (x instanceof IndexGetExpr){
				subStatements.add((x as IndexGetExpr).compile(statements))
			}
//			else if (x instanceof IndexSetExpr){
//				subStatements.add((x as IndexSetExpr).compile(statements))
			
		}
				
		return Joiner::on("").join(subStatements)
	}
	def CharSequence compile(IndexGetExpr expr, List<CharSequence> statements) {
		
		if (expr.eContainer !=null && expr.eContainer.eContainer instanceof AssignStatement){
			var parentExpression=expr.eContainer as Expression
			var assignment=expr.eContainer.eContainer as AssignStatement
			var isLastXp=(
				(parentExpression.terms==expr && parentExpression.continuation==null ) ||
				parentExpression.continuation.get(parentExpression.continuation.size-1)==expr
				
			)
						
			
			if (isLastXp && assignment.target==parentExpression){
				return '''->let(�expr.index.compile(statements)�,�assignment.source.compile(statements)�)'''
			}
		}
		
		
		return '''->get(�expr.index.compile(statements)�)'''
	}
	
	def compile(PropertyCallExpr expr,List<CharSequence> statements) {
		if (expr.eContainer !=null && expr.eContainer.eContainer instanceof AssignStatement){
			var parentExpression=expr.eContainer as Expression
			var assignment=expr.eContainer.eContainer as AssignStatement
			var isLastXp=(
				(parentExpression.terms==expr && parentExpression.continuation==null ) ||
				parentExpression.continuation.get(parentExpression.continuation.size-1)==expr
				
			)
						
			
			if (isLastXp && assignment.target==parentExpression){
				return '''->set_�expr.member.name�(�assignment.source.compile(statements)�)'''
			}
		}
		
		
		return '''->get_�expr.member.name�()'''
	}
	def lastTerm(Expression x){
		if (x.continuation==null || x.continuation.size==0)
			return x.terms
			
		return x.continuation.get(x.continuation.size-1)
	}
	def CharSequence compile(AssignStatement assign,List<CharSequence> statements) {
		
		if (assign.target.lastTerm instanceof IndexGetExpr) 
			return assign.target.compile(statements)
		
		if (assign.target.lastTerm instanceof PropertyCallExpr) 
			return assign.target.compile(statements)
			
			
		return assign.target.compile(statements)+" = "+assign.source.compile(statements)	
	}


	def compile(TerminalExpr x,List<CharSequence> statements) { 
		
		if (x instanceof MagicPhp){
			return (x as MagicPhp).compile(statements)
		}
		
		else if (x instanceof Literal){
			return(x as Literal).compile(statements)
		}
		else if (x instanceof Instantiation){
			return (x as Instantiation).compile(statements)
		}
		else if (x instanceof VarCall){
			return(x as VarCall).compile(statements)
		}
		return ""
		
	}

	
	def compile(Return decl,List<CharSequence> statements) 
		'''return �decl.xp.compile(statements)�'''
	
	
	def compile(LocalVarDecl decl,List<CharSequence> statements) 
	
		'''$�decl.name�=�decl.assignment.compile(statements)�'''
	
	
	def compile(Literal decl,List<CharSequence> statements){ 
	
		if (decl instanceof StringLiteral)
			return '''"�(decl as StringLiteral).value�"'''
		else if (decl instanceof IntegerLiteral)
			return (decl as IntegerLiteral).value.toString
		else if (decl instanceof DecimalLiteral)
			return (decl as DecimalLiteral).value.toString
		else if (decl instanceof DecimalLiteral)
			return (decl as DecimalLiteral).value.toString
		else if (decl instanceof HashLiteral)
			return (decl as HashLiteral).compile(statements)
	}
	def compile(HashLiteral decl,List<CharSequence> statements){ 
		return '''array(�FOR p:decl.pairs�
				�IF p.key instanceof StrKeyType��(p.key as StrKeyType).name.compile(statements)��ELSE�"�(p.key as IdKeyType).name�"�ENDIF�=>�p.value.compile(statements)�,
				�ENDFOR�
			)
		'''	
	}
	def compile(BinaryExpression decl,List<CharSequence> statements) 
		'''�decl.binaryOp��decl.terms.compile(statements)�'''
		
		
	def compile(UnaryExpression decl,List<CharSequence> statements) 
		//'''�decl.op.toString��decl.operand.compile(statements)�'''
		''''''
	def compile(Instantiation instantiation,List<CharSequence> statements){
		var varName="tmp_"+UUID::randomUUID().toString.replace("-","")
		statements.add('''$�varName�=new �instantiation.caller.fullyQualifiedName.toString("_")��instantiation.params.compile(statements)�''')
		return '''$�varName�'''	
	}
		

	def compile(ParamsCall params,List<CharSequence> statements){
		var lst=params.list
		var CharSequence result=""
		
		if (lst.size>0) {
			
				result=lst.get(lst.size-1).compile(statements)
				if (lst.size>1) {
					result='''( �FOR p:0..lst.size-2��lst.get(p).compile(statements)�,�ENDFOR� �result� )'''
				} else
					result='''( �result� )'''
				
		}
		else	
			result="()"
		return result
	}
	
	def CharSequence compile(ParamCall call,List<CharSequence> statements) {
//		var varName="tmp_"+UUID::randomUUID().toString.replace("-","")
//		statements.add('''$�varName�=�call.xp.compile(statements)�''')
		return call.xp.compile(statements)
	}

	

	
	def compile(Params params){
		
		var result=""
		
		if (params!=null && params.list!=null && params.list.size>0) {
			var lst=params.list
				result="$"+lst.get(lst.size-1).name
				if (lst.size>1) {
					result='''( �FOR p:0..lst.size-2�$�lst.get(p).name�,�ENDFOR� �result� )'''
				} else
					result='''( �result� )'''
				
		}
		else	
			result="()"
		return result
	}

	def compile(Method method) {
		
		''' 
			public function �method.name��method.params.compile� {
				�method.methodBody.compile�
			}
		'''
	}
	
	def compile(EntryPoint ep) ''' 
		$r = new Router();
		�FOR route : ep.entryPointBody.list�
			�route.compile�
		�ENDFOR�
		
		$r->run();
		
		
	'''
	
	def compile(Route route) 
		'''$r->map('�route.url�', array('controller' => '�route.ctrl.fullyQualifiedName.toString("_")�', 'action' => '�route.action.name�','view' => '�route.template�')); 
	'''

	def compile(VarCall call,List<CharSequence> statements){
		var name=""
		if (call.varKind instanceof Property)
			name="this->_"+(call.varKind as Property).name
		else if (call instanceof This )
			name="this"
		else if (call.varKind instanceof Param)
			name=(call.varKind as Param).name
		else if (call.varKind instanceof LocalVarDecl)
			name=(call.varKind as LocalVarDecl).name
			
		return "$"+name
	} 

	def compile(MethodCallExpr call,List<CharSequence> statements) {
		return '''->�call.member.name��call.methodsParams.compile(statements)�'''
	}
	
	
	def compile(MagicPhp mag,List<CharSequence> statements) 
		'''�mag.instr�'''
	def compile(MagicPhpBlock mag) 
		'''�mag.instr�'''
		
	def compileConstructorParam(Param prop) '''
		private $_�prop.name�;
		function set_�prop.name�($value) {
			$this->_�prop.name�=$value;	
		}
		
		function get_�prop.name�() {
			return $this->_�prop.name�;	
		}
	'''
	def compile(Property prop) '''
		private $_�prop.name�;
		function set_�prop.name�($value) {
			$this->_�prop.name�=$value;	
		}
		
		function get_�prop.name�() {
			return $this->_�prop.name�;	
		}
	'''
	
	def compile(EntityProperty prop) '''
		/**
		* �IF prop.key�@Id�ENDIF� @Column(type="�prop.propertyType.fullyQualifiedName.toString("_").toLowerCase�"�IF prop.column!=null�,name="�prop.column�"�ELSE�,name="�prop.propertyName�"�ENDIF�)
		**/
		private $_�prop.propertyName�;
		function set_�prop.propertyName�($value) {
			$this->_�prop.propertyName�=$value;	
		}
		
		function get_�prop.propertyName�() {
			return $this->_�prop.propertyName�;	
		}
	'''

}