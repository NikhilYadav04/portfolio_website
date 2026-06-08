import 'package:awesome_portfolio/models/app_model.dart';
import 'package:awesome_portfolio/models/color_model.dart';
import 'package:awesome_portfolio/models/device_model.dart';
import 'package:awesome_portfolio/screen/miniProjects/education/education.dart';
import 'package:awesome_portfolio/screen/miniProjects/experience/experience.dart';
import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/experience_model.dart';
import '../models/skill_model.dart';
import '../screen/miniProjects/about/about.dart';
import '../screen/miniProjects/playground/agent_playground.dart';
import '../screen/miniProjects/projects/projects.dart';
import '../screen/miniProjects/skills/skills.dart';

const double baseHeight = 790;
const double baseWidth = 1440;

List<DeviceModel> devices = [
  DeviceModel(
    device: Devices.android.onePlus8Pro,
    icon: Icons.android,
  ),
  DeviceModel(
    device: Devices.ios.iPhone13,
    icon: Icons.apple,
  ),
  DeviceModel(
    device: Devices.ios.iPad,
    icon: Icons.tablet,
  ),
];

List<ColorModel> colorPalette = [
  ColorModel(
    svgPath: "assets/images/cloudRed.svg",
    color: Colors.yellowAccent,
    gradient: const LinearGradient(
      begin: Alignment.bottomLeft,
      // transform: Grad,
      end: Alignment.topRight,
      colors: [Colors.yellowAccent, Colors.deepOrange],
    ),
  ),
  ColorModel(
    svgPath: "assets/images/cloudyBlue.svg",
    color: Colors.blue,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      colors: [Colors.blue, Colors.black45],
    ),
  ),
  ColorModel(
      svgPath: "assets/images/cloudyBlue.svg",
      color: const Color(0xff00d6ca),
      gradient: const LinearGradient(
        colors: [Color(0xff00ebd5), Color(0xff293474)],
        stops: [0, 1],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      )),
  ColorModel(
    svgPath: "assets/images/cloudyBlue.svg",
    color: const Color(0xff123cd1),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment(-0.31, 0.95),
      colors: [Color(0xFF1042F4), Color(0x00203EA6)],
    ),
  ),
  ColorModel(
    svgPath: "assets/images/cloudyBlue.svg",
    color: Colors.purple,
    gradient: const LinearGradient(
      colors: [Color(0xffc95edb), Colors.black12],
      stops: [0, 1],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  ColorModel(
    svgPath: "assets/images/cloudyBlue.svg",
    color: const Color(0xfff35a32),
    gradient: const LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [Colors.indigo, Colors.deepOrange], // Adjust colors as needed
    ),
  ),
];

/// Per-section accent for the home widget board. Each tile owns its own colour
/// (instead of the global mood accent) so the board reads as a colourful,
/// recognisable home screen rather than one flat palette.
const Map<String, List<Color>> sectionGradients = {
  "Playground": [Color(0xFF7C5CFF), Color(0xFF4D2FD6)], // violet
  "Skills": [Color(0xFF22D3EE), Color(0xFF0E8FB0)], // cyan
  "Experience": [Color(0xFFF7B733), Color(0xFFD98A00)], // amber
  "About": [Color(0xFF34D399), Color(0xFF0E9F6E)], // emerald
  "Projects": [Color(0xFFFB7185), Color(0xFFE11D62)], // rose
  "Education": [Color(0xFF60A5FA), Color(0xFF2563EB)], // blue
};

List<Color> sectionGradient(String title) =>
    sectionGradients[title] ?? const [Color(0xFF64748B), Color(0xFF334155)];

/// Short one-line subtitle shown under each section card on the home screen.
/// Placeholder copy — tune freely.
String appSubtitle(String title) {
  switch (title) {
    case "Playground":
      return "Live agent demos — workflow, RAG & in-app";
    case "About":
      return "Who I am, answered by my own assistant";
    case "Skills":
      return "Flutter · Agents · RAG — system monitor";
    case "Projects":
      return "Apps I've shipped, as a store";
    case "Experience":
      return "My career as a git log";
    case "Education":
      return "Where I studied";
    default:
      return "";
  }
}

List<AppModel> apps = [
  AppModel(
      title: "Playground",
      color: Colors.white,
      icon: Icons.smart_toy_outlined,
      screen: const AgentPlayground()),
  AppModel(
      title: "About",
      color: Colors.white,
      icon: Icons.person,
      screen: const AboutMe()),
  AppModel(
      title: "Skills",
      color: Colors.white,
      icon: Icons.insights,
      screen: const Skills()),
  AppModel(
      title: "Projects",
      color: Colors.white,
      icon: Icons.apps_rounded,
      screen: const Projects()),
  AppModel(
    title: "Youtube",
    assetPath: "assets/icons/youtube.svg",
    color: Colors.white,
    link: youtubeChannel,
  ),
  AppModel(
    title: "LinkedIn",
    assetPath: "assets/icons/linkedin.svg",
    color: Colors.white,
    link: linkedIn,
  ),
  AppModel(
    title: "Twitter/X",
    assetPath: "assets/icons/twitter.svg",
    color: Colors.white,
    link: twitter,
  ),
  AppModel(
    title: "Topmate",
    assetPath: "assets/icons/topMate.png",
    color: Colors.white,
    link: topMate,
  ),
  AppModel(
      title: "Experience",
      color: Colors.white,
      icon: FontAwesomeIcons.idBadge,
      screen: const Experience()),
  AppModel(
    title: "Education",
    color: Colors.white,
    icon: Icons.school_outlined,
    screen: const Education(),
  ),
  AppModel(
    title: "Github",
    assetPath: "assets/icons/github.svg",
    color: Colors.white,
    link: github,
  ),
  AppModel(
    title: "Play Store",
    assetPath: "assets/icons/playstore.svg",
    color: Colors.white,
    link: playApps,
  ),
];

final List<JobExperience> education = [
  JobExperience(
    color: Colors.red,
    location: "Patiala, India",
    title: 'Computer Engineering',
    company: 'Thapar Institure of Engineering',
    startDate: 'June 2021',
    endDate: 'Present',
    bulletPoints: [
      "Currently in the final year of my college!",
    ],
  ),
  JobExperience(
    color: Colors.blue,
    location: "Patiala, India",
    title: 'Diploma in Computer Science',
    company: 'Thapar Polytechnic College',
    startDate: 'June 2018',
    endDate: 'June 2021',
    bulletPoints: [
      'Some of the best years of college life',
    ],
  ),
];

final List<JobExperience> jobExperiences = [
  JobExperience(
    color: Colors.blue,
    location: "Banglore, India",
    title: 'Full Stack Developer',
    company: 'Stimuler',
    startDate: 'Feb 2023',
    endDate: 'Present',
    bulletPoints: [
      "Actively develop and manage push notifications to engage users effectively.",
      "Successfully set up in-app purchase functionality for both iOS and Android platforms.",
      "Utilize the Provider package for streamlined state management and implement real-time data streams.",
      "Employ Amplitude and Firebase Analytics to track and analyze user behavior, informing data-driven decisions.",
      "The Startup has over 3,00,000 lakh active users",
    ],
  ),
  // Add more job experiences here...
  JobExperience(
    color: Colors.redAccent,
    location: "Remote",
    title: 'Flutter Developer',
    company: 'Perpetuum India',
    startDate: 'Oct 2022',
    endDate: 'Jan 2023',
    bulletPoints: [
      "Establish voice calling functionality using Agora SDK to enable real-time communication within the app.",
      "Implement intricate animations using Rive, enhancing the app's visual appeal and engagement.",
      "Collaborate directly with Stanza Living's CTO, gaining insights into industry best practices and cutting-edge technologies.",
      "Acquire proficiency in server-driven UI setup, optimizing app flexibility and scalability through dynamic configuration.",
    ],
  ),
  JobExperience(
    color: Colors.orangeAccent,
    location: "Remote",
    title: 'App Architecture Intern',
    company: 'Habeato',
    startDate: 'Oct 2021',
    endDate: 'Nov 2021',
    bulletPoints: [
      "Collaborated with founders to develop a HealthifyMe clone, demonstrating strong teamwork and app development skills.",
      "Engineered complex animations to enhance user experience and app visual appeal.",
      "Played an active role in system design processes, contributing to efficient and scalable app architecture.",
    ],
  ),
  JobExperience(
    color: Colors.greenAccent,
    location: "Remote",
    title: 'App Developer',
    company: 'Kylo Apps',
    startDate: 'Sep 2021',
    endDate: 'Oct 2021',
    bulletPoints: [
      "Collaborated as a team member in developing a cryptocurrency wallet, akin to Trust Wallet, showcasing strong teamwork and blockchain app development expertise.",
      "Proficiently integrated REST APIs into the application, enhancing its functionality and connectivity with external services."
    ],
  ),
  JobExperience(
    color: Colors.black,
    location: "Remote",
    title: 'Flutter App Intern',
    company: 'Cogent Web Services',
    startDate: 'Dec 2020',
    endDate: 'June 2021',
    bulletPoints: [
      "Independently developed a Life Simulator game using Flutter from scratch, applying state-of-the-art state management practices to ensure a top-tier user experience.",
      "Leveraged Flutter's robust features to craft an immersive and captivating gameplay experience, demonstrating proficiency in app development.",
      "Successfully implemented Google Ads, in-app purchases, and Hive database for efficient user data storage and monetization strategies.",
      "Generated creative ideas for client pitches, fostering creativity and ensuring the game's entertainment value and thought-provoking nature.",
      "Published the game on the Play Store, achieving over 5,000 downloads, showcasing the ability to deliver a popular and engaging mobile application.",
    ],
  ),
];

// ---------------------------------------------------------------------------
// Phase 4 — live panel content. Placeholder copy; swap for your real details.
// ---------------------------------------------------------------------------

const String developerName = "Nikhil Yadav";
const String developerTagline = "Flutter Developer · AI Agent Engineer";
const String statusLine = "● currently building AI agents";
const String localTimezoneLabel = "IST";

/// Rotating quotes shown in the right panel under the mood picker.
const List<List<String>> rotatingQuotes = [
  ["Build agents that ship inside great apps.", "— working principle"],
  ["Don't run after success, run after perfection.", "— Rancho"],
  ["The best UI is the one that anticipates you.", "— design note"],
];

// ---------------------------------------------------------------------------
// Phase 4 — Projects "App Store". Placeholder cards; swap for real apps.
// ---------------------------------------------------------------------------

class ProjectApp {
  final String name;
  final String tagline;
  final IconData icon;
  final double rating;
  final String installs;
  final String link;
  final List<String> tags;
  const ProjectApp({
    required this.name,
    required this.tagline,
    required this.icon,
    required this.rating,
    required this.installs,
    required this.link,
    required this.tags,
  });
}

const List<ProjectApp> projectApps = [
  ProjectApp(
    name: "Stimuler",
    tagline: "AI English-coaching app · 300k+ users",
    icon: Icons.record_voice_over_outlined,
    rating: 4.6,
    installs: "300k+",
    link: "https://play.google.com/store/apps/developer?id=AppyMonk",
    tags: ["Flutter", "AI", "RAG"],
  ),
  ProjectApp(
    name: "Agent Workflows",
    tagline: "Tool-calling automation toolkit",
    icon: Icons.account_tree_outlined,
    rating: 4.8,
    installs: "open-source",
    link: "https://github.com/high-coder",
    tags: ["Agents", "Automation"],
  ),
  ProjectApp(
    name: "Life Simulator",
    tagline: "Flutter game · 5k+ downloads",
    icon: Icons.videogame_asset_outlined,
    rating: 4.3,
    installs: "5k+",
    link: "https://play.google.com/store/apps/developer?id=AppyMonk",
    tags: ["Flutter", "Game"],
  ),
];

const String youtubeChannel = "https://www.youtube.com/@highcoder";
const String linkedIn = "https://www.linkedin.com/in/high-coder/";
const String github = "https://github.com/high-coder";
const String twitter = "https://twitter.com/highcoder__";
const String instagram = "https://www.instagram.com/";
const String topMate = "https://topmate.io/highcoder";
const String resumeLink =
    "https://drive.google.com/file/d/1LO3Km6fFkJVW92MNXRLSYl--E9YlTHJd/view";
const String email = "deepakmittal941@gmail.com";
String introduction =
    "Welcome to my portfolio website, this website is highly inspired(almost copied) from Pawan Kumar.\n\nI am a Developer with 3 years of experience in flutter. Worked in many startups most recently worked with Stimuler an application that helps prepare students for Ielts and other english exams.\n\nWhen i am not developing I am mainly watching some movies or series or making stuff on Youtube or just watching fireship";
const String playApps =
    "https://play.google.com/store/apps/developer?id=AppyMonk";

// ---------------------------------------------------------------------------
// Phase 3 — About rebuilt as a RAG-style chat. Scripted Q&A "answered" from
// the portfolio's own data, each with source chips — a live sample of the kind
// of grounded assistant this developer builds. Placeholder copy.
// ---------------------------------------------------------------------------

class AboutQA {
  final String question;
  final String answer;
  final List<String> sources; // chip labels, e.g. "Experience", "Skills"
  const AboutQA(this.question, this.answer, this.sources);
}

const List<AboutQA> aboutChat = [
  AboutQA(
    "Who are you?",
    "I'm a developer working across two worlds: I ship polished Flutter apps, and I build AI agents — tool-calling workflows, RAG assistants, and agents that run inside the apps I make.",
    ["Skills", "About"],
  ),
  AboutQA(
    "What do you actually build?",
    "Mobile apps in Flutter end-to-end, plus automation: agents that call tools and chain steps, retrieval-grounded assistants over knowledge bases, and in-app AI features.",
    ["Playground", "Experience"],
  ),
  AboutQA(
    "What makes your mix unusual?",
    "Most agent developers can't ship a refined mobile app, and most Flutter devs don't build agents. I do both — so the AI lives natively inside great product UI.",
    ["Skills", "Playground"],
  ),
];

List<SkillsModel> skills = [
  SkillsModel(skillName: "Flutter", colorS: Colors.blue, iconPath: "random"),
  SkillsModel(
    skillName: "Firebase",
    colorS: Colors.yellow,
  ),
  SkillsModel(
    skillName: "Github",
    colorS: Colors.yellow,
  ),
  SkillsModel(
    skillName: "Dart",
    colorS: Colors.blue,
  ),
  SkillsModel(
    skillName: "Provider",
    colorS: Colors.orange,
  ),
  SkillsModel(
    skillName: "Riverpod",
    colorS: Colors.blue,
  ),
  SkillsModel(
    skillName: "CI/CD",
    colorS: Colors.yellow,
  ),
  SkillsModel(
    skillName: "Code Magic",
    colorS: Colors.orange,
  ),
  SkillsModel(
    skillName: "Firebase",
    colorS: Colors.yellow,
  ),
  SkillsModel(
    skillName: "REST API",
    colorS: Colors.yellow,
  ),
];

List<SkillsModel> languages = [
  SkillsModel(skillName: "Punjabi", colorS: Colors.orange),
  SkillsModel(skillName: "Hindi", colorS: Colors.black),
  SkillsModel(skillName: "English", colorS: Colors.blueGrey),
];

// ---------------------------------------------------------------------------
// Phase 3 — Skills "system monitor".
//
// Three tracks mirroring the portfolio's identity triad. `level` is 0..1 and
// drives each gauge's fill. Placeholder values — tune to taste.
// ---------------------------------------------------------------------------

class SkillStat {
  final String name;
  final double level; // 0..1
  const SkillStat(this.name, this.level);
}

class SkillTrack {
  final String name;
  final IconData icon;
  final List<SkillStat> stats;
  const SkillTrack(this.name, this.icon, this.stats);
}

const List<SkillTrack> skillTracks = [
  SkillTrack("Flutter", Icons.flutter_dash, [
    SkillStat("Flutter / Dart", 0.95),
    SkillStat("State mgmt (Provider/Riverpod)", 0.9),
    SkillStat("Animations & UI", 0.88),
    SkillStat("CI/CD · Codemagic", 0.8),
  ]),
  SkillTrack("Agents", Icons.account_tree_outlined, [
    SkillStat("Tool-calling / orchestration", 0.9),
    SkillStat("Workflow automation (n8n)", 0.85),
    SkillStat("Prompt & context engineering", 0.88),
    SkillStat("Eval & guardrails", 0.75),
  ]),
  SkillTrack("RAG / LLM", Icons.hub_outlined, [
    SkillStat("Retrieval & embeddings", 0.85),
    SkillStat("Vector stores", 0.8),
    SkillStat("Grounding & citations", 0.82),
    SkillStat("LLM APIs (Claude/OpenAI)", 0.9),
  ]),
];
