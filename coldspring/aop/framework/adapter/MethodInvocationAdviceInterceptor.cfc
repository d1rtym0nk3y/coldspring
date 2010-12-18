﻿<!---
   Copyright 2010 Mark Mandel
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
       http://www.apache.org/licenses/LICENSE-2.0
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 --->

<cfcomponent hint="Interceptor to pass along Menthod Interception to a target object" implements="coldspring.aop.MethodInterceptor" output="false">

<cfscript>
	meta = getMetadata(this);

	if(!structKeyExists(meta, "const"))
	{
		const = {};
		const.VALID_ADVICE_TYPES = ["before", "afterReturning", "around", "throws"];

		const.BEFORE_ADVICE = "before";
		const.AFTER_RETURNING_ADVICE = "afterReturning";
		const.AROUND_ADVICE = "around";
		const.THROWS_ADVICE = "throws";

		meta.const = const;
	}
</cfscript>

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="init" hint="Constructor" access="public" returntype="MethodInvocationAdviceInterceptor" output="false">
	<cfargument name="target" hint="The target in which the specified method should be used, as the AOP Interceptor" type="any" required="Yes">
	<cfargument name="method" hint="the AfterReturningAdvice to wrap" type="string" required="Yes">
	<cfargument name="adviceType" hint="The advice type: before,afterReturning,around,throws" type="string" required="Yes">
	<cfscript>
		if(!arrayContains(meta.const.VALID_ADVICE_TYPES, arguments.adviceType))
		{
			createObject("component", "coldspring.aop.framework.adapter.exception.InvalidAdviceTypeException").init(arguments.adviceType);
		}

		setTarget(arguments.target);
		setMethod(arguments.method);
		setAdviceType(arguments.adviceType);

		return this;
	</cfscript>
</cffunction>

<cffunction name="invokeMethod" hint="Implement this method to perform extra treatments before and after the invocation.<br/>Polite implementations would certainly like to invoke Joinpoint.proceed()." access="public" returntype="any" output="false">
	<cfargument name="methodInvocation" type="coldspring.aop.MethodInvocation" required="yes" />
	<cfscript>
	   var local = {};
	   local.type = getAdviceType();
    </cfscript>

	<cfif local.type eq meta.const.BEFORE_ADVICE>
		<cfinvoke component="#getTarget()#" method="#getMethod()#" argumentcollection="#arguments.methodInvocation.getArguments()#">
	</cfif>

	<cfif local.type eq meta.const.AROUND_ADVICE>
		<cfset local.args = {1=arguments.methodInvocation}>
		<cfinvoke component="#getTarget()#" method="#getMethod()#" argumentcollection="#local.args#" returnvariable="local.result">
	<cfelse>
		<cfset local.result = arguments.methodInvocation.proceed()>
	</cfif>

	<cfif structKeyExists(local, "result")>
		<cfreturn local.result />
	</cfif>
</cffunction>

<cffunction name="getTarget" access="public" returntype="any" output="false">
	<cfreturn instance.target />
</cffunction>

<cffunction name="setTarget" access="public" returntype="void" output="false">
	<cfargument name="target" type="any" required="true">
	<cfset instance.target = arguments.target />
</cffunction>

<cffunction name="getMethod" access="public" returntype="string" output="false">
	<cfreturn instance.method />
</cffunction>

<cffunction name="setMethod" access="public" returntype="void" output="false">
	<cfargument name="method" type="string" required="true">
	<cfset instance.method = arguments.method />
</cffunction>

<cffunction name="getAdviceType" access="private" returntype="string" output="false">
	<cfreturn instance.adviceType />
</cffunction>

<cffunction name="setAdviceType" access="private" returntype="void" output="false">
	<cfargument name="adviceType" type="string" required="true">
	<cfset instance.adviceType = arguments.adviceType />
</cffunction>


<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->




</cfcomponent>
