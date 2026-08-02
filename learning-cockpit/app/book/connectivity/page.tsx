import { VolumeBookIndex } from "../../foundation-volume";

export default function ConnectivityVolumePage() {
  return (
    <>
      <header className="volume-hero">
        <p className="eyebrow">VOLUME 02 / CONNECTIVITY</p>
        <h1>Follow the packet before blaming the network.</h1>
        <p>
          A request crosses interfaces, neighbor tables, routes, stateful devices,
          sockets, transports, names, encryption, and application hops. Learn each
          boundary, then identify the first one whose evidence differs from a healthy path.
        </p>
      </header>

      <section className="ubuntu-start">
        <div>
          <span>FIRST NETWORKING RULE</span>
          <h2>“The network is down” is not a diagnosis.</h2>
          <p>
            Name the source, destination, protocol, port, namespace, and expected path.
            Then test one boundary at a time: local socket, local route, next hop,
            transport outcome, name resolution, security, and application response.
          </p>
        </div>
        <div className="ubuntu-preflight">
          <strong>READ-ONLY PREFLIGHT</strong>
          <pre><code>{`cat /etc/os-release
ip -brief address
ip route show
ss -lntup
getent hosts localhost
python3 --version`}</code></pre>
          <p>
            These observations do not change network state. A missing optional tool is
            a documented dependency decision, never permission for an automatic install.
          </p>
        </div>
      </section>

      <section className="environment-facts">
        <article><span>TESTED</span><strong>Ubuntu 24.04</strong><p>WSL 2 is supported where the lesson does not require a distinct Linux network namespace.</p></article>
        <article><span>DEFAULT PRIVILEGE</span><strong>Non-root</strong><p>Labs use loopback or deterministic models; privileged packet or namespace work is separated and optional.</p></article>
        <article><span>DEFAULT NETWORK</span><strong>Offline</strong><p>Core exercises create no cloud account, public endpoint, paid resource, or production route.</p></article>
        <article><span>MASTERY</span><strong>Evidence-gated</strong><p>Reading and running a known command never prove independent packet-path reasoning.</p></article>
      </section>

      <VolumeBookIndex
        volumeId="02-connectivity"
        eyebrow="VOLUME 02 / CONNECTIVITY"
        heading="Build the path from a local frame to a reliable application exchange."
        introduction="Read in order. Draw the path, predict the next-hop and socket evidence, run the bounded lab, and explain where the first divergence occurs."
      />
    </>
  );
}
