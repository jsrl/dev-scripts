#!/bin/bash

echo "Enter the language (python, node, java, etc.): "
read lang

curl -sL "https://raw.githubusercontent.com/github/gitignore/main/$lang.gitignore" -o .gitignore

echo "✅ .gitignore for $lang created!"
