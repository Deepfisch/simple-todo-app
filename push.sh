#!/bin/bash

read -p "Введите текст коммита: " commit_msg

git status
git add .
git commit -m "$commit_msg"
git push