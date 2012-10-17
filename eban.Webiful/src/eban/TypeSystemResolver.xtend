package eban

import eban.webiful.BinaryExpression
import eban.webiful.Clazz
import eban.webiful.Controller
import eban.webiful.DataType
import eban.webiful.DecimalLiteral
import eban.webiful.Entity
import eban.webiful.Instantiation
import eban.webiful.IntegerLiteral
import eban.webiful.LocalVarDecl
//import eban.webiful.MemberCall
import eban.webiful.Method
import eban.webiful.Param
import eban.webiful.Property
import eban.webiful.Statement
import eban.webiful.StringLiteral
import eban.webiful.Type
import eban.webiful.UnaryExpression
import eban.webiful.VarCall
import org.eclipse.emf.ecore.EObject
import eban.webiful.PropertyCallExpr
import eban.webiful.MethodCallExpr
import eban.webiful.Expression
import eban.webiful.impl.MethodCallExprImpl
import eban.webiful.impl.PropertyCallExprImpl
import eban.webiful.WebifulPackage
import eban.webiful.impl.TypeImpl
import eban.webiful.impl.WebifulImpl
import eban.webiful.util.WebifulAdapterFactory
import eban.webiful.IndexGetExpr

class TypeSystemResolver {
	def Type resolveType(EObject x) {
		
		
		
		if (x instanceof Expression){
			return (x as Expression).resolveType()
//		} else if (x instanceof PropertyCallExpr &&  !(x as PropertyCallExprImpl).basicGetMember().eIsProxy){
//			
//			return (x as PropertyCallExpr).member.resolveType()
//		} else if (x instanceof MethodCallExpr  && !(x as MethodCallExprImpl).basicGetMember().eIsProxy){
//			return (x as MethodCallExpr).member.resolveType()
		} else if (x instanceof Instantiation){
			return (x as Instantiation).resolveType()
		} else if (x instanceof BinaryExpression){
			return(x as BinaryExpression).resolveType()
		}
		else if (x instanceof UnaryExpression){
			return(x as UnaryExpression).resolveType()
		}
		else if (x instanceof VarCall){
			return(x as VarCall).resolveType()
		}
		else if (x instanceof Property){
			return(x as Property).resolveType()
		}
		else if (x instanceof Method){
			return(x as Method).resolveType()
		}
		else if (x instanceof Param){
			return(x as Param).resolveType()
		}
		else if (x instanceof DecimalLiteral){
			return(x as DecimalLiteral).resolveType()
		}
		else if (x instanceof IntegerLiteral){
			return(x as IntegerLiteral).resolveType()
		}
		else if (x instanceof StringLiteral){
			return(x as StringLiteral).resolveType()
		}
		else if (x instanceof LocalVarDecl){
			return(x as LocalVarDecl).resolveType()
		}
		
		println("Unknown EObject :"+x)
		return null
					
	}
	def getTypeName(Type type){
		if (type instanceof Clazz){
			return (type as Clazz).name;
		
		} else if (type instanceof Entity){
			return (type as Entity).name;	
		
		} else if (type instanceof Controller){
			return (type as Controller).name;
		
		} else if (type instanceof DataType){
			return (type as DataType).name;
		
		}
		return "Unknown type"
		
		
	}
	
	def Type resolveType(Property instr) {
		return instr.propertyType
	}
	
	def Type resolveType(Param instr){
		return instr.type
	}
	def Type resolveType(DecimalLiteral instr){
		return null	
	}
	def Type resolveType(IntegerLiteral instr){
		return null
	}
	def Type resolveType(StringLiteral instr){
		return null
	}
	def Type resolveType(BinaryExpression instr){
		return resolveType(instr.terms)
	}
	def Type resolveType(Method instr,Type parent){
		var h=parent.eContents.filter(typeof(Method)).filter(m| m.name==instr.name).head
		return if (h==null) null else h.type
	}
	def Type resolveType(Property instr,Type parent){
		var h=parent.eContents.filter(typeof(Property)).filter(m| m.propertyName==instr.propertyName).head
		return if (h==null) null else h.propertyType
	}
	
	
	def Type resolveType(Expression instr,EObject context){
		var currentType=instr.terms.resolveType
		
		for (cont:instr.continuation){
			var Type newType=null
			if (cont == context) return currentType
			if (cont instanceof MethodCallExpr)
				newType=(cont as MethodCallExpr).member.type
			else if (cont instanceof PropertyCallExpr)
				newType=(cont as PropertyCallExpr).member.propertyType
			else if (cont instanceof IndexGetExpr)
				newType=(currentType.eContents.filter(typeof(Method)).filter(f|f.name=="get").head as Method).type
			else 
				newType=resolveType(cont)
				
			currentType=newType;	
			
		}
		
		return currentType
	}
	
	def Type resolveType(UnaryExpression instr){
		return resolveType(instr.terms)
	}
	
	def Type resolveType(LocalVarDecl instr){
		return instr.type
	}
	
	def Type resolveType(VarCall instr) {
		return resolveType(instr.varKind)
	}
	
	def Type resolveType(Method instr) {
		return instr.type
	}
	
	
	
//	def Type resolveType(MemberCall instr) {
//		println("Member is "+instr.member)
//		return resolveType(instr.member)
//	}
	
	def Type resolveType(Instantiation instr) {
		return instr.caller
	}
	
}