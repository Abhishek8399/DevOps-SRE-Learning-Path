import { VolumeBookIndex } from "../../foundation-volume";

export default function PrivateCloudVolumePage() {
  return (
    <>
      <header className="volume-hero">
        <p className="eyebrow">VOLUME 09 / PRIVATE CLOUD</p>
        <h1>Operate the physical-to-virtual request path as one system.</h1>
        <p>Learn virtualization, images, virtual networking, storage, control planes, capacity, failure domains, recovery, and the evidence needed to run private infrastructure safely.</p>
      </header>
      <section className="ubuntu-start">
        <div><span>FIRST PLATFORM RULE</span><h2>A virtual machine is still dependent on physical authority and finite hardware.</h2><p>Trace the caller, API, scheduler, hypervisor, image, network, storage, guest, application, and user-visible result before changing the platform.</p></div>
        <div className="ubuntu-preflight"><strong>READ-ONLY PREFLIGHT</strong><pre><code>{`uname -a
lscpu | sed -n '1,24p'
lsmod | grep -E '^kvm' || true
test -e /dev/kvm && ls -l /dev/kvm || true`}</code></pre><p>These commands inspect CPU and KVM capability. They create no VM and change no host setting.</p></div>
      </section>
      <VolumeBookIndex volumeId="09-private-cloud" eyebrow="VOLUME 09 / PRIVATE CLOUD" heading="Understand the substrate before operating the cloud." introduction="Begin with KVM and libvirt boundaries, then follow later chapters into OpenStack, Ceph, virtual networking, and bare-metal lifecycle." />
    </>
  );
}
