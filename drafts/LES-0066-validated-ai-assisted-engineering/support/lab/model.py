#!/usr/bin/env python3
"""Deterministic LES-0066 AI-system evidence-boundary model."""
from __future__ import annotations
import json
import pathlib
import sys

BOOLEAN_FIELDS = ("taskDefined","nonAiBaselineCompared","dataSplitClean","populationCoverage","metricMatchesCost","criticalEvidencePositionTested","embeddingContractPinned","retrievalBaselineMeasured","retrievalProvenanceRecorded","generationGrounded","citationsVerified","untrustedInstructionsTreatedAsData","toolSchemaClosed","leastPrivilegeTool","toolOutputValidated","idempotentEffects","humanReviewEffective","evalSetHeldOut","judgeCalibrated","versionLineageComplete","privacyLifecycleApproved","rollbackTested")
INTEGER_FIELDS = ("tokenCount","tokenBudget")
REQUIRED = {"id","expected",*BOOLEAN_FIELDS,*INTEGER_FIELDS}
DEFAULT_FIELDS = REQUIRED - {"id","expected"}
ORDERED_CHECKS = (
    ("taskDefined","task-contract"),("nonAiBaselineCompared","baseline"),
    ("dataSplitClean","data-leakage"),("populationCoverage","population"),
    ("metricMatchesCost","metric"),("criticalEvidencePositionTested","context-use"),
    ("embeddingContractPinned","embedding-contract"),
    ("retrievalBaselineMeasured","retrieval-baseline"),
    ("retrievalProvenanceRecorded","retrieval-provenance"),
    ("generationGrounded","grounding"),("citationsVerified","citation"),
    ("untrustedInstructionsTreatedAsData","instruction-trust"),
    ("toolSchemaClosed","tool-schema"),("leastPrivilegeTool","tool-authority"),
    ("toolOutputValidated","tool-output"),("idempotentEffects","side-effect"),
    ("humanReviewEffective","human-review"),("evalSetHeldOut","eval-integrity"),
    ("judgeCalibrated","judge-calibration"),
    ("versionLineageComplete","version-lineage"),
    ("privacyLifecycleApproved","privacy-lifecycle"),("rollbackTested","rollback"),
)

def load(path: str) -> dict:
    data=json.loads(pathlib.Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0066":
        raise ValueError("fixture identity")
    defaults,cases=data.get("defaults"),data.get("cases")
    if not isinstance(defaults,dict) or set(defaults) != DEFAULT_FIELDS:
        raise ValueError("defaults")
    if not isinstance(cases,list) or not cases:
        raise ValueError("cases")
    for field in BOOLEAN_FIELDS:
        if not isinstance(defaults[field],bool): raise ValueError(f"default boolean: {field}")
    for field in INTEGER_FIELDS:
        if not isinstance(defaults[field],int) or defaults[field] < 0: raise ValueError(f"default integer: {field}")
    seen=set(); normalized=[]
    for override in cases:
        if not isinstance(override,dict) or set(override)-REQUIRED or not {"id","expected"} <= set(override):
            raise ValueError("case fields")
        case=defaults|override
        if not isinstance(case["id"],str) or not case["id"] or case["id"] in seen: raise ValueError("case identity")
        if not isinstance(case["expected"],str) or not case["expected"]: raise ValueError("expected")
        seen.add(case["id"])
        for field in BOOLEAN_FIELDS:
            if not isinstance(case[field],bool): raise ValueError(f"boolean: {case['id']}:{field}")
        for field in INTEGER_FIELDS:
            if not isinstance(case[field],int) or case[field] < 0: raise ValueError(f"integer: {case['id']}:{field}")
        normalized.append(case)
    data["cases"]=normalized
    return data

def evaluate(case: dict) -> str:
    for field,boundary in ORDERED_CHECKS[:5]:
        if not case[field]: return boundary
    if case["tokenCount"] > case["tokenBudget"]: return "token-budget"
    for field,boundary in ORDERED_CHECKS[5:]:
        if not case[field]: return boundary
    return "operable"

def find_case(data: dict, case_id: str) -> dict:
    for case in data["cases"]:
        if case["id"] == case_id: return case
    raise ValueError("unknown case")

def main() -> int:
    if len(sys.argv) < 3: return 2
    command,path=sys.argv[1:3]; data=load(path)
    if command == "validate":
        print(f"fixture=valid cases={len(data['cases'])}"); return 0
    if command == "list":
        print("\n".join(case["id"] for case in data["cases"])); return 0
    if len(sys.argv) != 4: return 2
    case=find_case(data,sys.argv[3])
    if command == "show":
        print(json.dumps(case,indent=2,sort_keys=True)); return 0
    if command == "evaluate":
        boundary=evaluate(case); decision="operable" if boundary == "operable" else "not-operable"
        print(f"case={case['id']} decision={decision} boundary={boundary}")
        return 0 if boundary == case["expected"] else 1
    return 2

if __name__ == "__main__":
    raise SystemExit(main())
