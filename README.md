# jekyll-prototype

## Quick Start

### Install dependencies
```
pushd course_website
bundle install
npm install
popd
```

### Optional: Fetch content


```
ssh-add ${HOME}/bin/ssh/enote/ednote_rsa

ssh root@enote-devel3.compute.dtu.dk 'tar -cf - /enote/vol/content | gzip -9'  > ~/enote-vol-content-$(date +"%m-%d-%y").tgz

mkdir content
tar -xzvf ~/enote-vol-content-$(date +"%m-%d-%y").tgz -C content
```

### Transform content

(Assuming the environment variable `$DTU_ENOTE_VOL` points to a vol)

This script will transform the 2018 style Markdown files into AsciiDoctor files.


```.env
DTU_ENOTE_VOL=$(pwd) ./translator/translate.sh <course id>
```

### Run the Server

```
cd course_website
npm run start
```


