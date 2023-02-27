#!/bin/bash

# aqua.yaml hash: {{ include "dot_config/aquaproj-aqua/aqua.yaml" | sha256sum }}
aqua update-aqua
aqua i -a
