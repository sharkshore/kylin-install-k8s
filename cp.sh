#!/bin/bash

mkdir -p image/k8s/1.28.15
cp -r ~/docker_images/k8s/1.28.15 image/k8s/1.28.15
cp -r ~/packages/containerd .
cp -r ~/packages/kubernetes k8s

