# traktor
Traktor will autamically install Tor, polipo, dnscrypt-proxy and Tor Browser Launcher in a Debian based distro like Ubuntu and configures them as well.

To do this, just run 'traktor.sh' file in a supported shell like bash and watch for prompts it asks you.

## Important Note:
Do NOT expect anonymity using this method. Polipo is an http proxy and can leak data. If you need anonymity or strong privacy, download and use Tor Browser.

## Remote install
type in bash:

`curl -s https://github.com/ubuntu-ir/traktor/raw/master/traktor.sh | sh`
