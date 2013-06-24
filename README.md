Ecrawler
======================================
1. rebar Defining dependencies

	A dependency is defined by a triple {App, VsnRegex, Source} where:
	
	'App' specifies the OTP application name, either an atom or a string
	'VsnRegex' is a string containing a regular expression that must match the OTP application version string
	'Source' specifies the engine used to fetch the dependency along with an engine specific location:
	{hg, Url, Rev} Fetch from mercury repository
	{git, Url} Fetch from git repository
	{git, Url, {branch, Branch}} Fetch from git repository
	{git, Url, ""} == {git, Url, {branch, "HEAD"}} Fetch from git repository
	{git, Url, {tag, Tag}} Fetch from git repository
	{git, Url, Rev} Fetch from git repository
	{bzr, Url, Rev} Fetch from a bazaar repository
	
