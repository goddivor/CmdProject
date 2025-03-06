@echo off

set doc=%1

if a%1 equ a (
	start .
	) else (
	explorer %doc%
	)

set doc=