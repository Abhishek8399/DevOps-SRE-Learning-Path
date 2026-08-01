const foundations = [
  ["01", "Systems", "Linux, processes, memory, filesystems"],
  ["02", "Connectivity", "DNS, TCP, TLS, HTTP, routing"],
  ["03", "Engineering", "Git, Bash, Python, Go, testing"],
  ["04", "Delivery", "Containers, CI/CD, rollback, security"],
  ["05", "Reliability", "SLOs, telemetry, incidents, capacity"],
  ["06", "Platforms", "Kubernetes, IaC, self-service, upgrades"],
];

const tracks = [
  { name: "AWS and EKS", roles: "Experian / Mastercard / GitLab / ADP" },
  { name: "Private cloud", roles: "Cisco / NVIDIA / Arm" },
  { name: "Data and ML", roles: "Apple / Visa / NVIDIA" },
  { name: "CI compute", roles: "GitLab / NVIDIA / Arm" },
];

export default function CareerOverview() {
  return (
    <section className="career-panel" id="map">
      <div className="section-heading light">
        <div>
          <p className="eyebrow">YOUR FIELD MANUAL</p>
          <h2>One foundation. Four specialist directions.</h2>
          <p className="section-intro">
            Nine target roles use different tools, but they reward the same engineering loop:
            understand the path, prove the failure, recover safely, and prevent recurrence.
          </p>
        </div>
        <a className="text-link" href="#practice">Practice current lesson -&gt;</a>
      </div>

      <div className="career-map" aria-label="Role-driven learning architecture">
        <div className="foundation-column">
          <p className="map-label">SHARED FOUNDATION</p>
          {foundations.map(([number, name, detail]) => (
            <article className="foundation-row" key={number}>
              <span>{number}</span>
              <div><strong>{name}</strong><small>{detail}</small></div>
            </article>
          ))}
        </div>
        <div className="map-connector" aria-hidden="true">
          <span />
          <b>PROVEN<br />FUNDAMENTALS</b>
          <span />
        </div>
        <div className="track-column">
          <p className="map-label">SPECIALIST TRACKS</p>
          {tracks.map((track) => (
            <article className="track-card" key={track.name}>
              <strong>{track.name}</strong>
              <small>{track.roles}</small>
            </article>
          ))}
        </div>
      </div>

      <div className="operator-loop">
        <div><span>01</span><strong>Observe</strong><small>What changed for the user?</small></div>
        <b>-&gt;</b>
        <div><span>02</span><strong>Map</strong><small>Which boundary can fail?</small></div>
        <b>-&gt;</b>
        <div><span>03</span><strong>Prove</strong><small>What does evidence eliminate?</small></div>
        <b>-&gt;</b>
        <div><span>04</span><strong>Recover</strong><small>What is the smallest safe move?</small></div>
        <b>-&gt;</b>
        <div><span>05</span><strong>Prevent</strong><small>How will the system catch this?</small></div>
      </div>
    </section>
  );
}
