#!/usr/bin/env bash

cd codemirror
npm run prodserve &
cd ..

cd course_website
npm run start

