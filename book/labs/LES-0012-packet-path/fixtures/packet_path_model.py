#!/usr/bin/env python3
"""Deterministic, offline packet-path evidence model for LES-0012.

The model prints fixed key-value observations. It does not open sockets, inspect
host networking, start processes, sleep, or write files. Host mutation and
external network access are deliberately outside this fixture's design.
"""

from __future__ import annotations

import argparse
from typing import Dict, Mapping


CASES = ("baseline", "guided", "independent")
INCIDENT_CASES = ("guided", "independent")
VIEWS = ("addresses", "routes", "path")
PROBES = ("neighbor", "return", "mtu")

SCENARIOS: Dict[str, Dict[str, str]] = {
    "guided": {
        "record": "scenario",
        "case": "guided",
        "scenario_scope": "input-only",
        "operation": "synthetic-payment",
        "reported_symptom": "all-attempts-fail-before-peer-observation",
        "namespace": "virtual-source-blue",
        "source_cidr": "10.24.7.19/24",
        "destination_address": "10.44.7.25",
        "protocol": "tcp",
        "destination_port": "443",
        "policy_rules": "1000:from-10.24.7.0/24-lookup-blue,32766:lookup-main",
        "route_entries": "blue:10.44.7.0/24:blackhole:metric-5,blue:10.44.0.0/16:unicast:via-10.24.7.1:dev-eth0:metric-20,blue:0.0.0.0/0:unicast:via-10.24.7.254:dev-eth0:metric-100",
        "translation_config": "edge-a:snat-to-203.0.113.10",
        "return_route_entries": "edge-a:203.0.113.10/32:unicast",
        "application_response_bytes": "2600",
        "planned_largest_tcp_segment_payload_bytes": "1260",
        "ip_header_bytes": "20",
        "tcp_header_bytes": "20",
        "underlay_link_mtu": "1500",
        "encapsulation_overhead_bytes": "50",
        "pmtud_feedback_status": "unobserved",
    },
    "independent": {
        "record": "scenario",
        "case": "independent",
        "scenario_scope": "input-only",
        "operation": "synthetic-payment",
        "reported_symptom": "small-response-succeeds-large-response-stalls",
        "namespace": "virtual-source-green",
        "source_cidr": "10.88.4.12/23",
        "destination_address": "172.31.40.80",
        "protocol": "tcp",
        "destination_port": "443",
        "policy_rules": "900:from-10.88.4.0/23-lookup-green,32766:lookup-main",
        "route_entries": "green:172.31.40.0/24:unicast:via-10.88.4.1:dev-eth1:metric-20,green:172.31.0.0/16:unicast:via-10.88.4.254:dev-eth1:metric-10,green:0.0.0.0/0:unicast:via-10.88.4.254:dev-eth1:metric-100",
        "translation_config": "edge-b:snat-to-203.0.113.22",
        "return_route_entries": "edge-b:203.0.113.22/32:unicast",
        "application_response_bytes": "3000",
        "planned_largest_tcp_segment_payload_bytes": "1460",
        "ip_header_bytes": "20",
        "tcp_header_bytes": "20",
        "underlay_link_mtu": "1500",
        "encapsulation_overhead_bytes": "80",
        "pmtud_feedback_status": "unobserved",
    },
}



ADDRESSES: Dict[str, Dict[str, str]] = {
    "baseline": {
        "record": "observation",
        "case": "baseline",
        "view": "addresses",
        "namespace": "virtual-source-blue",
        "source_address": "10.24.7.19",
        "prefix_length": "24",
        "subnet_mask": "255.255.255.0",
        "network_address": "10.24.7.0",
        "broadcast_address": "10.24.7.255",
        "destination_address": "10.44.7.25",
        "gateway_on_link": "true",
        "destination_on_link": "false",
        "egress_interface": "eth0",
        "interface_mtu": "1500",
    },
    "guided": {
        "record": "observation",
        "case": "guided",
        "view": "addresses",
        "namespace": "virtual-source-blue",
        "source_address": "10.24.7.19",
        "prefix_length": "24",
        "subnet_mask": "255.255.255.0",
        "network_address": "10.24.7.0",
        "broadcast_address": "10.24.7.255",
        "destination_address": "10.44.7.25",
        "gateway_on_link": "true",
        "destination_on_link": "false",
        "egress_interface": "eth0",
        "interface_mtu": "1500",
    },
    "independent": {
        "record": "observation",
        "case": "independent",
        "view": "addresses",
        "namespace": "virtual-source-green",
        "source_address": "10.88.4.12",
        "prefix_length": "23",
        "subnet_mask": "255.255.254.0",
        "network_address": "10.88.4.0",
        "broadcast_address": "10.88.5.255",
        "destination_address": "172.31.40.80",
        "gateway_on_link": "true",
        "destination_on_link": "false",
        "egress_interface": "eth1",
        "interface_mtu": "1500",
    },
}


ROUTES: Dict[str, Dict[str, str]] = {
    "baseline": {
        "record": "observation",
        "case": "baseline",
        "view": "routes",
        "policy_rule": "priority-1000-from-10.24.7.0/24",
        "selected_table": "blue",
        "candidate_routes": "10.44.7.0/24:unicast,10.44.0.0/16:unicast,0.0.0.0/0:unicast",
        "winning_prefix": "10.44.7.0/24",
        "route_type": "unicast",
        "route_metric": "10",
        "source_address": "10.24.7.19",
        "next_hop": "10.24.7.1",
        "egress_interface": "eth0",
        "route_result": "selected",
    },
    "guided": {
        "record": "observation",
        "case": "guided",
        "view": "routes",
        "policy_rule": "priority-1000-from-10.24.7.0/24",
        "selected_table": "blue",
        "candidate_routes": "10.44.7.0/24:blackhole,10.44.0.0/16:unicast,0.0.0.0/0:unicast",
        "winning_prefix": "10.44.7.0/24",
        "route_type": "blackhole",
        "route_metric": "5",
        "source_address": "10.24.7.19",
        "next_hop": "none",
        "egress_interface": "none",
        "route_result": "rejected",
    },
    "independent": {
        "record": "observation",
        "case": "independent",
        "view": "routes",
        "policy_rule": "priority-900-from-10.88.4.0/23",
        "selected_table": "green",
        "candidate_routes": "172.31.40.0/24:unicast,172.31.0.0/16:unicast,0.0.0.0/0:unicast",
        "winning_prefix": "172.31.40.0/24",
        "route_type": "unicast",
        "route_metric": "20",
        "source_address": "10.88.4.12",
        "next_hop": "10.88.4.1",
        "egress_interface": "eth1",
        "route_result": "selected",
    },
}


PATHS: Dict[str, Dict[str, str]] = {
    "baseline": {
        "record": "observation",
        "case": "baseline",
        "view": "path",
        "neighbor_target": "10.24.7.1",
        "neighbor_state": "reachable",
        "original_tuple": "10.24.7.19:49152-10.44.7.25:443-tcp",
        "translated_tuple": "203.0.113.10:40001-10.44.7.25:443-tcp",
        "translation_state": "present",
        "forward_result": "delivered",
        "return_route": "203.0.113.10/32-via-edge-a",
        "reverse_state": "present",
        "application_response_bytes": "2600",
        "tcp_segment_count": "3",
        "largest_tcp_segment_payload_bytes": "1260",
        "ip_header_bytes": "20",
        "tcp_header_bytes": "20",
        "largest_emitted_ip_packet_bytes": "1300",
        "underlay_link_mtu": "1500",
        "encapsulation_overhead_bytes": "50",
        "effective_inner_ip_mtu": "1450",
        "largest_encapsulated_packet_bytes": "1350",
        "mtu_headroom_bytes": "150",
        "mtu_result": "fits",
        "control_feedback": "not-needed",
        "ttl_out": "63",
        "operation_success": "true",
    },
    "guided": {
        "record": "observation",
        "case": "guided",
        "view": "path",
        "neighbor_target": "not-reached",
        "neighbor_state": "not-queried",
        "original_tuple": "10.24.7.19:49152-10.44.7.25:443-tcp",
        "translated_tuple": "not-created",
        "translation_state": "not-created",
        "forward_result": "route-rejected",
        "return_route": "not-evaluated",
        "reverse_state": "not-created",
        "application_response_bytes": "2600",
        "tcp_segment_count": "0",
        "largest_tcp_segment_payload_bytes": "not-emitted",
        "ip_header_bytes": "20",
        "tcp_header_bytes": "20",
        "largest_emitted_ip_packet_bytes": "not-emitted",
        "underlay_link_mtu": "1500",
        "encapsulation_overhead_bytes": "50",
        "effective_inner_ip_mtu": "1450",
        "largest_encapsulated_packet_bytes": "not-emitted",
        "mtu_headroom_bytes": "not-evaluated",
        "mtu_result": "not-tested",
        "control_feedback": "not-needed",
        "ttl_out": "not-decremented",
        "operation_success": "false",
    },
    "independent": {
        "record": "observation",
        "case": "independent",
        "view": "path",
        "neighbor_target": "10.88.4.1",
        "neighbor_state": "reachable",
        "original_tuple": "10.88.4.12:53000-172.31.40.80:443-tcp",
        "translated_tuple": "203.0.113.22:41017-172.31.40.80:443-tcp",
        "translation_state": "present",
        "forward_result": "delivered",
        "return_route": "203.0.113.22/32-via-edge-b",
        "reverse_state": "present",
        "application_response_bytes": "3000",
        "tcp_segment_count": "3",
        "largest_tcp_segment_payload_bytes": "1460",
        "ip_header_bytes": "20",
        "tcp_header_bytes": "20",
        "largest_emitted_ip_packet_bytes": "1500",
        "underlay_link_mtu": "1500",
        "encapsulation_overhead_bytes": "80",
        "effective_inner_ip_mtu": "1420",
        "largest_encapsulated_packet_bytes": "1580",
        "mtu_headroom_bytes": "-80",
        "mtu_result": "exceeds",
        "control_feedback": "missing",
        "ttl_out": "61",
        "operation_success": "false",
    },
}


PROBE_RESULTS: Dict[str, Dict[str, Dict[str, str]]] = {
    "baseline": {
        "neighbor": {"record": "probe", "case": "baseline", "probe": "neighbor", "target": "10.24.7.1", "interface": "eth0", "state": "reachable", "samples": "1", "scope": "virtual-single-lookup"},
        "return": {"record": "probe", "case": "baseline", "probe": "return", "reply_destination": "203.0.113.10", "selected_route": "203.0.113.10/32-via-edge-a", "state_owner": "edge-a", "reverse_state": "present", "result": "selected", "scope": "virtual-single-lookup"},
        "mtu": {"record": "probe", "case": "baseline", "probe": "mtu", "small_ip_packet_bytes": "1200", "small_encapsulated_packet_bytes": "1250", "small_result": "delivered", "large_ip_packet_bytes": "1400", "large_encapsulated_packet_bytes": "1450", "large_result": "delivered", "underlay_link_mtu": "1500", "encapsulation_overhead_bytes": "50", "effective_inner_ip_mtu": "1450", "large_mtu_headroom_bytes": "50", "control_feedback": "not-needed", "scope": "virtual-two-size-sample"},
    },
    "guided": {
        "neighbor": {"record": "probe", "case": "guided", "probe": "neighbor", "target": "not-reached", "interface": "none", "state": "not-queried", "samples": "1", "scope": "virtual-single-lookup"},
        "return": {"record": "probe", "case": "guided", "probe": "return", "reply_destination": "not-created", "selected_route": "not-evaluated", "state_owner": "none", "reverse_state": "not-created", "result": "not-evaluated", "scope": "virtual-single-lookup"},
        "mtu": {"record": "probe", "case": "guided", "probe": "mtu", "small_ip_packet_bytes": "1200", "small_encapsulated_packet_bytes": "1250", "small_result": "not-sent", "large_ip_packet_bytes": "1400", "large_encapsulated_packet_bytes": "1450", "large_result": "not-sent", "underlay_link_mtu": "1500", "encapsulation_overhead_bytes": "50", "effective_inner_ip_mtu": "1450", "large_mtu_headroom_bytes": "50", "control_feedback": "not-needed", "scope": "virtual-two-size-sample"},
    },
    "independent": {
        "neighbor": {"record": "probe", "case": "independent", "probe": "neighbor", "target": "10.88.4.1", "interface": "eth1", "state": "reachable", "samples": "1", "scope": "virtual-single-lookup"},
        "return": {"record": "probe", "case": "independent", "probe": "return", "reply_destination": "203.0.113.22", "selected_route": "203.0.113.22/32-via-edge-b", "state_owner": "edge-b", "reverse_state": "present", "result": "selected", "scope": "virtual-single-lookup"},
        "mtu": {"record": "probe", "case": "independent", "probe": "mtu", "small_ip_packet_bytes": "1200", "small_encapsulated_packet_bytes": "1280", "small_result": "delivered", "large_ip_packet_bytes": "1500", "large_encapsulated_packet_bytes": "1580", "large_result": "dropped", "underlay_link_mtu": "1500", "encapsulation_overhead_bytes": "80", "effective_inner_ip_mtu": "1420", "large_mtu_headroom_bytes": "-80", "control_feedback": "missing", "scope": "virtual-two-size-sample"},
    },
}


BASELINE: Dict[str, str] = {
    "record": "baseline",
    "case": "baseline",
    "operation": "synthetic-payment",
    "source_address": ADDRESSES["baseline"]["source_address"],
    "source_prefix": ADDRESSES["baseline"]["network_address"] + "/24",
    "destination_address": ADDRESSES["baseline"]["destination_address"],
    "winning_prefix": ROUTES["baseline"]["winning_prefix"],
    "route_type": ROUTES["baseline"]["route_type"],
    "next_hop": ROUTES["baseline"]["next_hop"],
    "neighbor_state": PATHS["baseline"]["neighbor_state"],
    "translation_state": PATHS["baseline"]["translation_state"],
    "forward_result": PATHS["baseline"]["forward_result"],
    "return_route": PATHS["baseline"]["return_route"],
    "reverse_state": PATHS["baseline"]["reverse_state"],
    "application_response_bytes": PATHS["baseline"]["application_response_bytes"],
    "tcp_segment_count": PATHS["baseline"]["tcp_segment_count"],
    "largest_tcp_segment_payload_bytes": PATHS["baseline"]["largest_tcp_segment_payload_bytes"],
    "ip_header_bytes": PATHS["baseline"]["ip_header_bytes"],
    "tcp_header_bytes": PATHS["baseline"]["tcp_header_bytes"],
    "largest_emitted_ip_packet_bytes": PATHS["baseline"]["largest_emitted_ip_packet_bytes"],
    "underlay_link_mtu": PATHS["baseline"]["underlay_link_mtu"],
    "encapsulation_overhead_bytes": PATHS["baseline"]["encapsulation_overhead_bytes"],
    "effective_inner_ip_mtu": PATHS["baseline"]["effective_inner_ip_mtu"],
    "largest_encapsulated_packet_bytes": PATHS["baseline"]["largest_encapsulated_packet_bytes"],
    "mtu_headroom_bytes": PATHS["baseline"]["mtu_headroom_bytes"],
    "mtu_result": PATHS["baseline"]["mtu_result"],
    "control_feedback": PATHS["baseline"]["control_feedback"],
    "ttl_out": PATHS["baseline"]["ttl_out"],
    "operation_success": PATHS["baseline"]["operation_success"],
}


def recovery(case_name: str) -> Dict[str, str]:
    guided = case_name == "guided"
    return {
        "record": "recovery",
        "case": case_name,
        "action": "restore-specific-unicast-route" if guided else "clamp-tcp-mss-to-1380",
        "winning_prefix": "10.44.7.0/24" if guided else "172.31.40.0/24",
        "route_type": "unicast",
        "neighbor_state": "reachable",
        "translation_state": "present",
        "return_route": "compatible",
        "reverse_state": "present",
        "segmentation_strategy": "existing-1260-byte-tcp-segments" if guided else "tcp-mss-clamp-1380",
        "application_response_bytes": "2600" if guided else "3000",
        "tcp_segment_count": "3",
        "largest_tcp_segment_payload_bytes": "1260" if guided else "1380",
        "ip_header_bytes": "20",
        "tcp_header_bytes": "20",
        "largest_emitted_ip_packet_bytes": "1300" if guided else "1420",
        "underlay_link_mtu": "1500",
        "encapsulation_overhead_bytes": "50" if guided else "80",
        "effective_inner_ip_mtu": "1450" if guided else "1420",
        "largest_encapsulated_packet_bytes": "1350" if guided else "1500",
        "mtu_headroom_bytes": "150" if guided else "0",
        "mtu_result": "fits",
        "operation_success": "true",
    }


def verification(case_name: str) -> Dict[str, str]:
    guided = case_name == "guided"
    return {
        "record": "verification",
        "case": case_name,
        "operation": "synthetic-payment",
        "forward_result": "delivered",
        "return_result": "delivered",
        "translation_state": "present",
        "reverse_state": "present",
        "segmentation_strategy": "existing-1260-byte-tcp-segments" if guided else "tcp-mss-clamp-1380",
        "application_response_bytes": "2600" if guided else "3000",
        "tcp_segment_count": "3",
        "largest_tcp_segment_payload_bytes": "1260" if guided else "1380",
        "ip_header_bytes": "20",
        "tcp_header_bytes": "20",
        "largest_emitted_ip_packet_bytes": "1300" if guided else "1420",
        "underlay_link_mtu": "1500",
        "encapsulation_overhead_bytes": "50" if guided else "80",
        "effective_inner_ip_mtu": "1450" if guided else "1420",
        "largest_encapsulated_packet_bytes": "1350" if guided else "1500",
        "mtu_headroom_bytes": "150" if guided else "0",
        "mtu_result": "fits",
        "operation_success": "true",
        "verification_scope": "deterministic-model-only",
    }


def emit(items: Mapping[str, str]) -> None:
    """Print a stable, single-line key-value record."""

    for key, value in items.items():
        if not key or "=" in key or "\n" in key or "\r" in key:
            raise ValueError("invalid output key")
        if not value or "\n" in value or "\r" in value:
            raise ValueError(f"invalid output value for {key}")
        print(f"{key}={value}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Emit deterministic offline packet-path evidence."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("baseline")

    observe_parser = subparsers.add_parser("observe")
    observe_parser.add_argument("--case", required=True, choices=CASES)
    observe_parser.add_argument("--view", required=True, choices=VIEWS)

    probe_parser = subparsers.add_parser("probe")
    probe_parser.add_argument("--case", required=True, choices=CASES)
    probe_parser.add_argument("--probe", required=True, choices=PROBES)
    scenario_parser = subparsers.add_parser("scenario")
    scenario_parser.add_argument("--case", required=True, choices=INCIDENT_CASES)



    for command in ("recover", "verify"):
        command_parser = subparsers.add_parser(command)
        command_parser.add_argument("--case", required=True, choices=INCIDENT_CASES)

    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.command == "baseline":
        emit(BASELINE)
    elif args.command == "scenario":
        emit(SCENARIOS[args.case])
    elif args.command == "observe":
        views = {"addresses": ADDRESSES, "routes": ROUTES, "path": PATHS}
        emit(views[args.view][args.case])
    elif args.command == "probe":
        emit(PROBE_RESULTS[args.case][args.probe])
    elif args.command == "recover":
        emit(recovery(args.case))
    elif args.command == "verify":
        emit(verification(args.case))
    else:
        raise AssertionError(f"unhandled command: {args.command}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
