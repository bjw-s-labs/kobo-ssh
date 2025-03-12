# kobo-ssh

This repository contains the tools needed to compile [dropbear](https://matt.ucc.asn.au/dropbear/dropbear.html) and [sftp-server](https://github.com/openssh/openssh-portable) for the `arm-kobo-linux-gnueabihf` system (all recent [Kobo](https://www.kobo.com/) products).
This binary is used for root shell access on Kobo devices which, in my case, is used to deploy and debug software on e-readers. As of now, these binaries have been tested on a Kobo Libra H2o and a Kobo Libra 2.

### Features:
- Recent Dropbear version
- `scp` to the SSH server works
- Host keys will be generated automatically as required.

## Compiling locally

This project can be compiled locally by running the `compile.sh` script. This requires Docker or a compatible container engine to be installed.

```sh
./compile.sh
```

This will compile all the required binaries and generate a `dist/KoboRoot.tgz` file.

## Prebuilt binaries

A prebuilt KoboRoot.tgz can be found on the [releases page](https://github.com/bjw-s-labs/kobo-ssh/releases).

## Kobo setup

Once you have generated the `KoboRoot.tgz` file you can transfer this to your Kobo device by connecting the device to your computer and placing the file in the `.kobo` folder on the exposed drive.

Finally, disconnect the device from your computer and wait for it to restart. Once the restart is complete you should have a working SSH server.

## Credits

Many thanks to the following for their original work on this subject:
- https://github.com/Ewpratten/KoboSSH
- https://github.com/obynio/kobopatch-ssh
