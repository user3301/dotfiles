{ pkgs, ... }:

{

  # Development packages
  home.packages = with pkgs; [
    # Golang
    go
    pkgs.golangci-lint

    # C# (.NET SDK 8.0.421)
    dotnet-sdk_8

    # Protobuf
    protobuf_33
    protoc-gen-go-grpc
    protoc-gen-go

    # Python
    python314

    # Nodejs
    nodejs_24
  ];

}
