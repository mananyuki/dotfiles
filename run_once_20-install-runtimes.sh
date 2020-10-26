#!/bin/bash

plugins=(direnv eksctl golang helm java kubectl nodejs rust sbt scala terraform)

direnv=2.23.0
eksctl=0.29.2
golang=1.15.2
helm=3.3.4
java=corretto-11.0.8.10.1
kubectl=1.19.2
nodejs=15.0.0
rust=1.47.0
sbt=1.4.1
scala=2.13.3
terraform=0.12.23

for e in ${plugins[@]}; do
  asdf plugin-add $e
  asdf install $e ${!e}
  asdf global $e ${!e}
done

python2=2.7.15
python3=3.9.0

asdf plugin-add python
asdf install python $python2
asdf install python $python3
asdf global python $python3 $python2

pip install pynvim
