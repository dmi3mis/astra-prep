#!/bin/bash

git clone https://github.com/dmi3mis/astra-prep && cd astra-prep/
git checkout aldpro-3.2.1-on-alse1.7.10
cd environments/local
terragrunt run -- init
terragrunt run -- apply