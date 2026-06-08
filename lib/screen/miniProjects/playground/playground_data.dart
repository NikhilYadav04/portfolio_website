import 'package:flutter/material.dart';

/// Phase 3 — Agent Playground data.
///
/// Each playground tab is a *scripted but technically honest* agent run: an
/// ordered list of [AgentStep]s the UI reveals one at a time, so a visitor
/// watches the real shape of the loop (plan → act → observe → answer) instead
/// of a vague "thinking" spinner. Content is placeholder; swap freely.

enum StepKind {
  /// The model reasoning / planning a move.
  think,

  /// Calling an external tool / API.
  tool,

  /// Reading back a tool/result observation.
  observe,

  /// Retrieving documents (RAG).
  retrieve,

  /// Taking an action on a UI (in-app agent).
  act,

  /// Final grounded answer / done.
  answer,
}

class AgentStep {
  final StepKind kind;

  /// Short label shown on the step node, e.g. "Call CRM API".
  final String label;

  /// Optional secondary detail (the tool payload, the retrieved snippet, etc.).
  final String? detail;

  const AgentStep(this.kind, this.label, {this.detail});
}

class AgentDemo {
  final String title;
  final String subtitle;

  /// The user-facing prompt that kicks the run off (shown as the task).
  final String prompt;
  final List<AgentStep> steps;

  const AgentDemo({
    required this.title,
    required this.subtitle,
    required this.prompt,
    required this.steps,
  });
}

IconData stepIcon(StepKind kind) {
  switch (kind) {
    case StepKind.think:
      return Icons.psychology_outlined;
    case StepKind.tool:
      return Icons.api_outlined;
    case StepKind.observe:
      return Icons.visibility_outlined;
    case StepKind.retrieve:
      return Icons.find_in_page_outlined;
    case StepKind.act:
      return Icons.touch_app_outlined;
    case StepKind.answer:
      return Icons.check_circle_outline;
  }
}

String stepKindLabel(StepKind kind) {
  switch (kind) {
    case StepKind.think:
      return "PLAN";
    case StepKind.tool:
      return "TOOL";
    case StepKind.observe:
      return "OBSERVE";
    case StepKind.retrieve:
      return "RETRIEVE";
    case StepKind.act:
      return "ACT";
    case StepKind.answer:
      return "DONE";
  }
}

/// Tab 1 — tool-calling / workflow agents.
const AgentDemo workflowDemo = AgentDemo(
  title: "Workflow Agent",
  subtitle: "Tool-calling • multi-step automation",
  prompt: "New lead arrived — enrich it and notify the team.",
  steps: [
    AgentStep(StepKind.think, "Plan the steps",
        detail: "enrich → score → route → notify"),
    AgentStep(StepKind.tool, "Call enrichment API",
        detail: "GET /enrich?email=lead@acme.com"),
    AgentStep(StepKind.observe, "Read result",
        detail: "Acme Corp · 200 emp · fintech"),
    AgentStep(StepKind.tool, "Score lead",
        detail: "model → score = 0.86 (hot)"),
    AgentStep(StepKind.tool, "Post to Slack",
        detail: "#sales · 'Hot lead: Acme Corp'"),
    AgentStep(StepKind.answer, "Workflow complete",
        detail: "4 tools called · 1.2s"),
  ],
);

/// Tab 2 — conversational / RAG assistants.
const AgentDemo ragDemo = AgentDemo(
  title: "RAG Assistant",
  subtitle: "Retrieve • ground • cite",
  prompt: "What's our refund policy for annual plans?",
  steps: [
    AgentStep(StepKind.think, "Understand the question",
        detail: "intent: refund · scope: annual"),
    AgentStep(StepKind.retrieve, "Search knowledge base",
        detail: "3 chunks from policy.pdf, faq.md"),
    AgentStep(StepKind.observe, "Rank sources",
        detail: "[1] policy.pdf p.4 · [2] faq.md"),
    AgentStep(StepKind.answer, "Grounded answer",
        detail:
            "Annual plans are refundable within 14 days, pro-rated after. [1][2]"),
  ],
);

/// Tab 3 — agents inside Flutter apps (the unfair advantage).
const AgentDemo inAppDemo = AgentDemo(
  title: "In-App Agent",
  subtitle: "Agent driving a real Flutter UI",
  prompt: "Book me the 9 AM slot and confirm.",
  steps: [
    AgentStep(StepKind.think, "Locate booking screen",
        detail: "screen: /appointments"),
    AgentStep(StepKind.act, "Tap '9:00 AM'", detail: "slot selected"),
    AgentStep(StepKind.act, "Fill notes field", detail: "'Follow-up visit'"),
    AgentStep(StepKind.act, "Tap 'Confirm'", detail: "submitting…"),
    AgentStep(StepKind.answer, "Booked", detail: "Confirmation #A2391"),
  ],
);

const List<AgentDemo> playgroundDemos = [workflowDemo, ragDemo, inAppDemo];
