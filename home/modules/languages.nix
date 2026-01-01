{ config, pkgs, lib, ... }:

{

  # Development packages
  home.packages = with pkgs; [
    # Golang
    go
    pkgs.golangci-lint
    
    # Protobuf
    protobuf_33
    protoc-gen-go-grpc
    protoc-gen-go

    # Python
    python314

    # Nodejs
    nodejs_24
  ]

}
