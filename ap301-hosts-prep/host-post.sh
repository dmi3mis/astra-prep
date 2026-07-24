#!/bin/bash

git clone https://github.com/dmi3mis/astra-prep && cd astra-prep/
git checkout ap301
cd environments/local
terragrunt run -- init
terragrunt run -- apply