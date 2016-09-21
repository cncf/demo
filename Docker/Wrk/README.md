## Summary

This is an Alpine based image with curl and [wrk](https://github.com/wg/wrk) (HTTP benchmarking tool). 

## Usage

To try it out, simply pass a URL:

docker run -e URL="http://google.com" zilman/wrk

runner.sh is a simple wrapper around the wrk command. 

Pass enviorment variables to override any of the defaults:

- DURATION
- CONNECTIONS
- THREADS
- TIMEOUT

Summary results are curl'd to an endpoint as defined in the included lua script.
Set your own location by exporting PUSHGATEWAY.

#### Tip

You can poke around by doing:
docker run --entrypoint /bin/sh --rm -ti zilman/wrk
