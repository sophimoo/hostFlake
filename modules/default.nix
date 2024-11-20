{ pkgs, lib, ... }:
{

  imports = [

    lib.filesystem.listFilesRecursive ./.

  ];

}
