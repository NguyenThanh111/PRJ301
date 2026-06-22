<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NetGuard — Network Management Platform</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --bg-0: #04060d;
            --bg-1: #0a1020;
            --surface: rgba(14, 20, 36, 0.78);
            --surface-2: rgba(20, 28, 48, 0.75);
            --border: rgba(146, 167, 223, 0.25);
            --text-primary: #f3f6ff;
            --text-muted: #a2b0d4;
            --neon-purple: #8b5cf6;
            --neon-pink: #d946ef;
            --neon-blue: #60a5fa;
            --danger: #ef4444;
            --accent: var(--neon-purple);
            --radius-sm: 8px;
            --radius-md: 12px;
            --radius-lg: 20px;
            --radius-xl: 28px;
            --cubic-spring: cubic-bezier(0.32, 0.72, 0, 1);
        }

        * { box-sizing: border-box; }
        html { scroll-behavior: smooth; }

        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            color: var(--text-primary);
            background: var(--bg-0);
            overflow-x: hidden;
        }

        .bg-video {
            position: fixed;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0.3;
            z-index: -2;
            filter: saturate(1.2) contrast(1.05);
        }

        .bg-fixed {
            position: fixed;
            inset: 0;
            z-index: -3;
            background:
                linear-gradient(135deg, #03050c 0%, #090f1d 45%, #04060d 100%);
        }

        .bg-grid {
            position: fixed;
            inset: 0;
            z-index: -1;
            background-image:
                linear-gradient(to right, rgba(255, 255, 255, 0.04) 1px, transparent 1px),
                linear-gradient(to bottom, rgba(255, 255, 255, 0.03) 1px, transparent 1px);
            background-size: 72px 72px;
            opacity: .2;
            pointer-events: none;
        }

        .bg-orb {
            position: fixed;
            border-radius: 50%;
            filter: blur(80px);
            pointer-events: none;
            z-index: -1;
        }

        .bg-orb-1 {
            width: 500px;
            height: 500px;
            background: rgba(139, 92, 246, 0.08);
            top: -160px;
            right: -120px;
        }

        .bg-orb-2 {
            width: 400px;
            height: 400px;
            background: rgba(217, 70, 239, 0.06);
            bottom: 10%;
            left: -100px;
        }

        .bg-orb-3 {
            width: 350px;
            height: 350px;
            background: rgba(96, 165, 250, 0.05);
            bottom: 40%;
            right: 20%;
        }

        .nav-island {
            position: fixed;
            top: 18px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 1000;
            display: flex;
            align-items: center;
            gap: 0;
            padding: 6px 8px 6px 18px;
            border-radius: 999px;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(8, 12, 28, 0.72);
            backdrop-filter: blur(24px);
            box-shadow: 0 12px 48px rgba(0, 0, 0, 0.5);
            transition: transform 0.4s var(--cubic-spring), box-shadow 0.4s ease;
        }

        .nav-island:hover {
            box-shadow: 0 16px 56px rgba(0, 0, 0, 0.6), 0 0 0 1px rgba(139, 92, 246, 0.15);
        }

        .nav-logo {
            display: flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            color: var(--text-primary);
            font-weight: 800;
            font-size: 15px;
            letter-spacing: .02em;
            margin-right: 14px;
        }

        .nav-logo-icon {
            width: 30px;
            height: 30px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--neon-purple), var(--neon-pink));
            color: #04060d;
            font-size: 15px;
            box-shadow: 0 0 16px rgba(139, 92, 246, 0.3);
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 2px;
            list-style: none;
            margin: 0;
            padding: 0;
        }

        .nav-links a {
            text-decoration: none;
            color: #b7c4e6;
            font-size: 13px;
            font-weight: 500;
            padding: 6px 12px;
            border-radius: 999px;
            transition: all 0.3s var(--cubic-spring);
        }

        .nav-links a:hover {
            color: #e8eeff;
            background: rgba(255, 255, 255, 0.06);
        }

        .nav-links a.active {
            color: var(--neon-purple);
            background: rgba(139, 92, 246, 0.1);
        }

        .nav-actions {
            display: flex;
            align-items: center;
            gap: 6px;
            margin-left: 10px;
        }

        .nav-btn {
            text-decoration: none;
            padding: 7px 16px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.35s var(--cubic-spring);
        }

        .nav-btn-outline {
            border: 1px solid rgba(255, 255, 255, 0.15);
            color: #d0daff;
            background: transparent;
        }

        .nav-btn-outline:hover {
            border-color: rgba(139, 92, 246, 0.4);
            color: var(--neon-purple);
            background: rgba(139, 92, 246, 0.06);
        }

        .nav-btn-solid {
            background: linear-gradient(135deg, var(--neon-purple), var(--neon-pink));
            color: #04060d;
            border: none;
            box-shadow: 0 4px 16px rgba(139, 92, 246, 0.25);
        }

        .nav-btn-solid:hover {
            box-shadow: 0 6px 24px rgba(139, 92, 246, 0.35);
            transform: scale(1.02);
        }

        .hero {
            min-height: 100dvh;
            display: flex;
            align-items: center;
            padding: 120px 40px 80px;
            max-width: 1280px;
            margin: 0 auto;
        }

        .hero-inner {
            display: grid;
            grid-template-columns: 1.1fr 0.9fr;
            gap: 60px;
            align-items: center;
            width: 100%;
        }

        .hero-left { position: relative; }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 14px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 600;
            letter-spacing: .1em;
            text-transform: uppercase;
            border: 1px solid rgba(139, 92, 246, 0.3);
            background: rgba(139, 92, 246, 0.08);
            color: #c4b5fd;
            margin-bottom: 20px;
        }

        .hero-badge i { font-size: 10px; }

        .hero-title {
            margin: 0 0 18px;
            font-size: clamp(48px, 6.5vw, 82px);
            font-weight: 800;
            line-height: 1.05;
            letter-spacing: -.02em;
        }

        .hero-title .highlight {
            background: linear-gradient(135deg, var(--neon-purple), var(--neon-pink));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .hero-sub {
            margin: 0 0 36px;
            font-size: 18px;
            line-height: 1.6;
            color: #c5ceec;
            max-width: 560px;
        }

        .hero-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .btn-primary {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 14px 28px;
            border-radius: 999px;
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
            background: linear-gradient(135deg, var(--neon-purple), var(--neon-pink));
            color: #04060d;
            border: none;
            cursor: pointer;
            box-shadow: 0 8px 28px rgba(139, 92, 246, 0.28);
            transition: all 0.4s var(--cubic-spring);
        }

        .btn-primary:hover {
            box-shadow: 0 12px 40px rgba(139, 92, 246, 0.35);
            transform: translateY(-2px);
        }

        .btn-primary:active {
            transform: scale(0.97);
        }

        .btn-primary .btn-icon {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: rgba(4, 6, 13, 0.15);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            transition: transform 0.3s var(--cubic-spring);
        }

        .btn-primary:hover .btn-icon {
            transform: translateX(3px) scale(1.05);
        }

        .btn-secondary {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 14px 24px;
            border-radius: 999px;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            border: 1px solid rgba(255, 255, 255, 0.12);
            color: #d0daff;
            background: rgba(255, 255, 255, 0.04);
            transition: all 0.35s var(--cubic-spring);
        }

        .btn-secondary:hover {
            border-color: rgba(255, 255, 255, 0.22);
            background: rgba(255, 255, 255, 0.08);
            transform: translateY(-1px);
        }

        .hero-right {
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
        }

        .hero-graph {
            position: relative;
            width: 100%;
            max-width: 480px;
            aspect-ratio: 1;
        }

        .graph-ring {
            position: absolute;
            border-radius: 50%;
            border: 1px solid rgba(139, 92, 246, 0.12);
        }

        .graph-ring-1 { width: 100%; height: 100%; top: 0; left: 0; animation: spin 30s linear infinite; }
        .graph-ring-2 { width: 80%; height: 80%; top: 10%; left: 10%; animation: spin-reverse 24s linear infinite; border-color: rgba(139, 92, 246, 0.08); }
        .graph-ring-3 { width: 55%; height: 55%; top: 22.5%; left: 22.5%; animation: spin 20s linear infinite; border-color: rgba(217, 70, 239, 0.1); }

        @keyframes spin { to { transform: rotate(360deg); } }
        @keyframes spin-reverse { to { transform: rotate(-360deg); } }

        .graph-dot {
            position: absolute;
            width: 8px;
            height: 8px;
            border-radius: 50%;
        }

        .graph-dot-purple { background: var(--neon-purple); box-shadow: 0 0 12px rgba(139, 92, 246, 0.6); }
        .graph-dot-pink { background: var(--neon-pink); box-shadow: 0 0 12px rgba(217, 70, 239, 0.6); }
        .graph-dot-blue { background: var(--neon-blue); box-shadow: 0 0 12px rgba(96, 165, 250, 0.6); }

        .graph-line {
            position: absolute;
            height: 2px;
            border-radius: 2px;
            transform-origin: left center;
        }

        .graph-line-purple { background: linear-gradient(90deg, var(--neon-purple), transparent); }
        .graph-line-pink { background: linear-gradient(90deg, var(--neon-pink), transparent); }

        .graph-center {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: rgba(139, 92, 246, 0.08);
            border: 1px solid rgba(139, 92, 246, 0.25);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            color: var(--neon-purple);
            box-shadow: 0 0 40px rgba(139, 92, 246, 0.08);
            animation: pulse-glow 3s ease-in-out infinite;
        }

        @keyframes pulse-glow {
            0%, 100% { box-shadow: 0 0 40px rgba(139, 92, 246, 0.08); }
            50% { box-shadow: 0 0 60px rgba(139, 92, 246, 0.15); }
        }

        section {
            padding: 100px 40px;
        }

        .section-label {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 600;
            letter-spacing: .12em;
            text-transform: uppercase;
            border: 1px solid rgba(139, 92, 246, 0.25);
            background: rgba(139, 92, 246, 0.07);
            color: #c4b5fd;
            margin-bottom: 12px;
        }

        .section-title {
            font-size: clamp(30px, 3.4vw, 46px);
            font-weight: 800;
            margin: 0 0 16px;
            line-height: 1.1;
            letter-spacing: -.015em;
        }

        .section-desc {
            font-size: 16px;
            color: #c5ceec;
            max-width: 560px;
            line-height: 1.6;
            margin: 0 0 40px;
        }

        .container-narrow {
            max-width: 1280px;
            margin: 0 auto;
        }

        /* ── Stats Bento ── */
        .stats-bento {
            display: grid;
            grid-template-columns: 1.8fr 1fr 1fr;
            gap: 12px;
        }

        .bento-card {
            border-radius: var(--radius-lg);
            border: 1px solid rgba(255, 255, 255, 0.06);
            background: linear-gradient(180deg, rgba(14, 20, 36, 0.72), rgba(10, 14, 28, 0.85));
            backdrop-filter: blur(8px);
            padding: 24px;
            transition: all 0.4s var(--cubic-spring);
            position: relative;
            overflow: hidden;
        }

        .bento-card:hover {
            border-color: rgba(139, 92, 246, 0.2);
            transform: translateY(-3px);
            box-shadow: 0 16px 48px rgba(0, 0, 0, 0.3);
        }

        .bento-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(139, 92, 246, 0.2), transparent);
            opacity: 0;
            transition: opacity 0.4s ease;
        }

        .bento-card:hover::before {
            opacity: 1;
        }

        .bento-colspan-2 {
            grid-column: span 1;
            grid-row: span 2;
        }

        .bento-card-double {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .bento-card-half {
            grid-row: span 1;
        }

        .bento-header {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 14px;
        }

        .bento-icon {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }

        .bento-icon-purple { background: rgba(139, 92, 246, 0.12); color: var(--neon-purple); }
        .bento-icon-pink { background: rgba(217, 70, 239, 0.12); color: var(--neon-pink); }
        .bento-icon-blue { background: rgba(96, 165, 250, 0.12); color: var(--neon-blue); }
        .bento-icon-danger { background: rgba(239, 68, 68, 0.12); color: var(--danger); }

        .bento-label {
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 500;
        }

        .bento-value {
            font-size: 36px;
            font-weight: 800;
            line-height: 1;
            margin-bottom: 4px;
        }

        .bento-value-purple { color: var(--neon-purple); }
        .bento-value-pink { color: var(--neon-pink); }
        .bento-value-blue { color: var(--neon-blue); }
        .bento-value-danger { color: var(--danger); }

        .bento-detail {
            font-size: 12px;
            color: #8d9ec6;
            margin-top: 4px;
        }

        .bento-subgrid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-top: 8px;
        }

        .bento-subgrid .bento-card {
            padding: 18px;
        }

        .bento-subgrid .bento-value {
            font-size: 26px;
        }

        /* ── Features Zigzag ── */
        .features-grid {
            display: grid;
            gap: 80px;
        }

        .feature-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 60px;
            align-items: center;
        }

        .feature-row:nth-child(even) .feature-visual {
            order: -1;
        }

        .feature-visual {
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .feature-mock {
            width: 100%;
            max-width: 420px;
            border-radius: var(--radius-lg);
            border: 1px solid rgba(255, 255, 255, 0.06);
            background: linear-gradient(180deg, rgba(14, 20, 36, 0.7), rgba(10, 14, 28, 0.8));
            padding: 28px 24px;
            position: relative;
        }

        .feature-mock-header {
            display: flex;
            align-items: center;
            gap: 6px;
            margin-bottom: 14px;
        }

        .feature-mock-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
        }

        .feature-mock-content {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .feature-mock-bar {
            height: 10px;
            border-radius: 5px;
            background: rgba(255, 255, 255, 0.06);
            overflow: hidden;
        }

        .feature-mock-bar-fill {
            height: 100%;
            border-radius: 5px;
            background: linear-gradient(90deg, var(--neon-purple), rgba(139, 92, 246, 0.3));
        }

        .feature-mock-bar-fill.pink { background: linear-gradient(90deg, var(--neon-pink), rgba(217, 70, 239, 0.3)); }
        .feature-mock-bar-fill.blue { background: linear-gradient(90deg, var(--neon-blue), rgba(96, 165, 250, 0.3)); }

        .feature-tag {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: .06em;
            text-transform: uppercase;
        }

        .feature-tag-purple { background: rgba(139, 92, 246, 0.1); color: var(--neon-purple); }
        .feature-tag-pink { background: rgba(217, 70, 239, 0.1); color: var(--neon-pink); }
        .feature-tag-blue { background: rgba(96, 165, 250, 0.1); color: var(--neon-blue); }

        .feature-text h3 {
            font-size: 24px;
            font-weight: 700;
            margin: 0 0 10px;
        }

        .feature-text p {
            font-size: 14px;
            line-height: 1.65;
            color: #c5ceec;
            margin: 0 0 16px;
        }

        .feature-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            font-weight: 600;
            color: var(--neon-purple);
            text-decoration: none;
            transition: gap 0.3s var(--cubic-spring);
        }

        .feature-link:hover {
            gap: 10px;
        }

        .infra-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
        }

        .infra-card {
            border-radius: var(--radius-lg);
            border: 1px solid rgba(255, 255, 255, 0.06);
            background: linear-gradient(180deg, rgba(14, 20, 36, 0.6), rgba(10, 14, 28, 0.75));
            padding: 28px 20px;
            text-align: center;
            transition: all 0.4s var(--cubic-spring);
        }

        .infra-card:hover {
            border-color: rgba(139, 92, 246, 0.25);
            transform: translateY(-4px);
            box-shadow: 0 16px 40px rgba(0, 0, 0, 0.3);
        }

        .infra-icon {
            width: 52px;
            height: 52px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            margin: 0 auto 14px;
        }

        .infra-card h4 {
            font-size: 15px;
            font-weight: 700;
            margin: 0 0 4px;
        }

        .infra-card p {
            font-size: 12px;
            color: var(--text-muted);
            margin: 0;
            line-height: 1.4;
        }

        .steps-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
        }

        .step-card {
            border-radius: var(--radius-lg);
            border: 1px solid rgba(255, 255, 255, 0.06);
            background: linear-gradient(180deg, rgba(14, 20, 36, 0.6), rgba(10, 14, 28, 0.75));
            padding: 32px 24px;
            text-align: center;
            transition: all 0.4s var(--cubic-spring);
            position: relative;
        }

        .step-card:hover {
            border-color: rgba(139, 92, 246, 0.2);
            transform: translateY(-3px);
        }

        .step-number {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            font-weight: 800;
            margin: 0 auto 16px;
            background: linear-gradient(135deg, var(--neon-purple), var(--neon-pink));
            color: #04060d;
        }

        .step-card h4 {
            font-size: 16px;
            font-weight: 700;
            margin: 0 0 8px;
        }

        .step-card p {
            font-size: 13px;
            color: #c5ceec;
            margin: 0;
            line-height: 1.5;
        }

        /* ── Alerts ── */
        .alerts-list {
            display: flex;
            flex-direction: column;
        }

        .alert-row {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 14px 18px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.04);
            transition: background 0.25s ease;
            border-radius: var(--radius-sm);
        }

        .alert-row:last-child { border-bottom: none; }
        .alert-row:hover { background: rgba(255, 255, 255, 0.03); }

        .severity-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            flex-shrink: 0;
        }

        .severity-critical { background: var(--danger); box-shadow: 0 0 12px rgba(239, 68, 68, 0.5); }
        .severity-warning { background: var(--neon-blue); box-shadow: 0 0 12px rgba(96, 165, 250, 0.5); }
        .severity-info { background: var(--neon-purple); box-shadow: 0 0 12px rgba(139, 92, 246, 0.4); }

        .alert-content {
            flex: 1;
            min-width: 0;
        }

        .alert-message {
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 2px;
        }

        .alert-meta {
            font-size: 11px;
            color: #8d9ec6;
        }

        .alert-empty {
            padding: 32px;
            text-align: center;
            color: #8d9ec6;
            font-size: 13px;
        }

        /* ── CTA ── */
        .cta-section {
            text-align: center;
            padding: 120px 40px;
        }

        .cta-box {
            max-width: 700px;
            margin: 0 auto;
            border-radius: var(--radius-xl);
            border: 1px solid rgba(139, 92, 246, 0.1);
            background: linear-gradient(180deg, rgba(14, 20, 36, 0.6), rgba(10, 14, 28, 0.7));
            padding: 60px 40px;
            position: relative;
            overflow: hidden;
        }

        .cta-box::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle at 50% 30%, rgba(139, 92, 246, 0.04), transparent 50%);
            pointer-events: none;
        }

        .cta-title {
            font-size: clamp(28px, 3vw, 40px);
            font-weight: 800;
            margin: 0 0 12px;
        }

        .cta-desc {
            font-size: 15px;
            color: #c5ceec;
            margin: 0 0 32px;
            max-width: 480px;
            margin-left: auto;
            margin-right: auto;
        }

        .cta-actions {
            display: flex;
            justify-content: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        /* ── Footer ── */
        .footer {
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            padding: 40px;
        }

        .footer-inner {
            max-width: 1280px;
            margin: 0 auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .footer-brand {
            display: flex;
            align-items: center;
            gap: 6px;
            font-weight: 700;
            font-size: 13px;
            color: #d0daff;
        }

        .footer-copy {
            font-size: 12px;
            color: #7f8db4;
        }

        /* ── Scroll Animation ── */
        .reveal {
            opacity: 0;
            transform: translateY(40px);
            transition: opacity 0.8s ease, transform 0.8s var(--cubic-spring);
        }

        .reveal.visible {
            opacity: 1;
            transform: translateY(0);
        }

        .reveal-delay-1 { transition-delay: 0.1s; }
        .reveal-delay-2 { transition-delay: 0.2s; }
        .reveal-delay-3 { transition-delay: 0.3s; }
        .reveal-delay-4 { transition-delay: 0.4s; }

        /* ── Responsive ── */
        @media (max-width: 900px) {
            .hero { padding: 100px 20px 60px; }
            .hero-inner { grid-template-columns: 1fr; gap: 40px; }
            .hero-right { display: none; }
            .hero-title { font-size: 36px; }

            .infra-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .steps-grid {
                grid-template-columns: 1fr;
                gap: 16px;
            }

            .stats-bento {
                grid-template-columns: 1fr 1fr;
            }

            .bento-colspan-2 {
                grid-column: span 2;
            }

            .feature-row {
                grid-template-columns: 1fr;
                gap: 30px;
            }

            .feature-row:nth-child(even) .feature-visual {
                order: 0;
            }

            .feature-visual { order: -1; }

            section { padding: 60px 20px; }
            .cta-section { padding: 80px 20px; }
            .cta-box { padding: 40px 24px; }

            .nav-links, .nav-actions .nav-btn-outline { display: none; }

            .nav-island {
                padding: 6px 14px 6px 14px;
                top: 12px;
            }

            .footer-inner {
                flex-direction: column;
                gap: 10px;
                text-align: center;
            }
        }

        @media (max-width: 600px) {
            .stats-bento {
                grid-template-columns: 1fr;
            }
            .bento-colspan-2 {
                grid-column: span 1;
            }
            .bento-subgrid {
                grid-template-columns: 1fr;
            }
            .hero-title { font-size: 30px; }
            .hero-actions { flex-direction: column; align-items: flex-start; }
            .cta-actions { flex-direction: column; align-items: center; }

            .infra-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

<video class="bg-video" autoplay muted loop playsinline>
    <source src="theme/original-bbd8c0ff4dbd70e3f804581b5b16a73f.mp4" type="video/mp4">
</video>
<div class="bg-fixed"></div>
<div class="bg-grid"></div>
<div class="bg-orb bg-orb-1"></div>
<div class="bg-orb bg-orb-2"></div>
<div class="bg-orb bg-orb-3"></div>

<nav class="nav-island">
    <a href="<c:url value='/home'/>" class="nav-logo">
        <span class="nav-logo-icon"><i class="bi bi-shield-shaded"></i></span>
        NetGuard
    </a>
    <ul class="nav-links">
        <li><a href="#hero" class="active">Home</a></li>
        <li><a href="#features">Features</a></li>
        <li><a href="#alerts">Status</a></li>
    </ul>
    <div class="nav-actions">
        <a href="login.jsp" class="nav-btn nav-btn-outline">Sign In</a>
        <a href="user-form.jsp?source=normal" class="nav-btn nav-btn-solid">Get Started</a>
    </div>
</nav>

<section class="hero" id="hero">
    <div class="hero-inner">
        <div class="hero-left reveal visible">
            <div class="hero-badge">
                <i class="bi bi-shield-check"></i> Real-time Network Intelligence
            </div>
            <h1 class="hero-title">
                Monitor, manage<br>
                <span class="highlight">secure your network</span>
            </h1>
            <p class="hero-sub">
                Centralized platform for tracking routers, access points, switches, and devices.
                Get real-time alerts, bandwidth analytics, and maintenance scheduling across your entire campus network.
            </p>
            <div class="hero-actions">
                <a href="login.jsp" class="btn-primary">
                    <span>Launch Dashboard</span>
                    <span class="btn-icon"><i class="bi bi-arrow-right"></i></span>
                </a>
                <a href="#features" class="btn-secondary">
                    <i class="bi bi-info-circle"></i> Learn More
                </a>
            </div>
            <div style="display:flex;gap:24px;margin-top:36px;flex-wrap:wrap;">
                <div style="display:flex;align-items:center;gap:8px;font-size:13px;color:#b7c4e6;">
                    <i class="bi bi-check-circle-fill" style="color:var(--neon-pink);font-size:11px;"></i>
                    <span>Real-time monitoring</span>
                </div>
                <div style="display:flex;align-items:center;gap:8px;font-size:13px;color:#b7c4e6;">
                    <i class="bi bi-check-circle-fill" style="color:var(--neon-pink);font-size:11px;"></i>
                    <span>Alert management</span>
                </div>
                <div style="display:flex;align-items:center;gap:8px;font-size:13px;color:#b7c4e6;">
                    <i class="bi bi-check-circle-fill" style="color:var(--neon-pink);font-size:11px;"></i>
                    <span>Bandwidth analytics</span>
                </div>
                <div style="display:flex;align-items:center;gap:8px;font-size:13px;color:#b7c4e6;">
                    <i class="bi bi-check-circle-fill" style="color:var(--neon-pink);font-size:11px;"></i>
                    <span>Maintenance scheduling</span>
                </div>
            </div>
        </div>
        <div class="hero-right reveal visible reveal-delay-2">
            <div class="hero-graph">
                <div class="graph-ring graph-ring-1">
                    <span class="graph-dot graph-dot-purple" style="top: 4%; left: 50%;"></span>
                    <span class="graph-dot graph-dot-pink" style="top: 50%; left: 96%;"></span>
                    <span class="graph-dot graph-dot-purple" style="top: 96%; left: 50%;"></span>
                    <span class="graph-dot graph-dot-blue" style="top: 50%; left: 4%;"></span>
                </div>
                <div class="graph-ring graph-ring-2">
                    <span class="graph-dot graph-dot-pink" style="top: 12%; left: 20%;"></span>
                    <span class="graph-dot graph-dot-purple" style="top: 80%; left: 75%;"></span>
                    <span class="graph-dot graph-dot-blue" style="top: 35%; left: 88%;"></span>
                </div>
                <div class="graph-ring graph-ring-3">
                    <span class="graph-dot graph-dot-purple" style="top: 8%; left: 50%;"></span>
                    <span class="graph-dot graph-dot-pink" style="top: 50%; left: 92%;"></span>
                    <span class="graph-dot graph-dot-blue" style="top: 92%; left: 50%;"></span>
                </div>
                <div class="graph-line graph-line-purple" style="width: 140px; top: 28%; left: 32%; transform: rotate(-22deg);"></div>
                <div class="graph-line graph-line-pink" style="width: 120px; top: 62%; left: 28%; transform: rotate(18deg);"></div>
                <div class="graph-line graph-line-purple" style="width: 100px; top: 18%; left: 56%; transform: rotate(45deg);"></div>
                <div class="graph-center">
                    <i class="bi bi-shield-fill-check"></i>
                </div>
            </div>
        </div>
    </div>
</section>

<section id="infrastructure" style="padding-top:0;">
    <div class="container-narrow">
        <div class="reveal" style="text-align:center;margin-bottom:40px;">
            <span class="section-label">Infrastructure</span>
            <h2 class="section-title" style="text-align:center;max-width:500px;margin-left:auto;margin-right:auto;">
                Supported equipment
            </h2>
            <p class="section-desc" style="text-align:center;margin-left:auto;margin-right:auto;">
                Monitor and manage every layer of your network hardware from a single dashboard.
            </p>
        </div>
        <div class="infra-grid reveal reveal-delay-1">
            <div class="infra-card">
                <div class="infra-icon" style="background:rgba(139,92,246,0.12);color:var(--neon-purple);">
                    <i class="bi bi-router"></i>
                </div>
                <h4>Routers</h4>
                <p>IP, MAC, firmware, status, location</p>
            </div>
            <div class="infra-card">
                <div class="infra-icon" style="background:rgba(217,70,239,0.12);color:var(--neon-pink);">
                    <i class="bi bi-reception-4"></i>
                </div>
                <h4>Access Points</h4>
                <p>SSID, channel, connected clients, load</p>
            </div>
            <div class="infra-card">
                <div class="infra-icon" style="background:rgba(96,165,250,0.12);color:var(--neon-blue);">
                    <i class="bi bi-hdd-network"></i>
                </div>
                <h4>Switches</h4>
                <p>Port status, VLAN, throughput, health</p>
            </div>
            <div class="infra-card">
                <div class="infra-icon" style="background:rgba(139,92,246,0.12);color:var(--neon-purple);">
                    <i class="bi bi-laptop"></i>
                </div>
                <h4>End Devices</h4>
                <p>MAC, IP, owner, type, allow/block</p>
            </div>
        </div>
    </div>
</section>

<section id="stats" style="padding-top: 40px;">
    <div class="container-narrow">
        <div class="stats-bento reveal">
            <div class="bento-card bento-card-double bento-colspan-2">
                <div>
                    <div class="bento-header">
                        <span class="bento-icon bento-icon-purple"><i class="bi bi-shield-check"></i></span>
                        <span class="bento-label">System Overview</span>
                    </div>
                    <div class="bento-value bento-value-purple">
                        <c:choose>
                            <c:when test="${not empty routerTotal}">
                                ${routerTotal + apTotal + switchTotal + deviceTotal}
                            </c:when>
                            <c:otherwise>--</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="bento-detail">Total managed devices across all categories</div>
                </div>
                <div class="bento-subgrid">
                    <div class="bento-card">
                        <div class="bento-header">
                            <span class="bento-icon bento-icon-purple"><i class="bi bi-router"></i></span>
                            <span class="bento-label">Routers</span>
                        </div>
                        <div class="bento-value bento-value-purple">
                            <c:choose>
                                <c:when test="${not empty routerTotal}">${routerTotal}</c:when>
                                <c:otherwise>--</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="bento-detail">
                            <c:choose>
                                <c:when test="${not empty routerOnline}">${routerOnline} online · ${routerOffline} offline</c:when>
                                <c:otherwise>Loading...</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="bento-card">
                        <div class="bento-header">
                            <span class="bento-icon bento-icon-pink"><i class="bi bi-reception-4"></i></span>
                            <span class="bento-label">Access Points</span>
                        </div>
                        <div class="bento-value bento-value-pink">
                            <c:choose>
                                <c:when test="${not empty apTotal}">${apTotal}</c:when>
                                <c:otherwise>--</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="bento-detail">
                            <c:choose>
                                <c:when test="${not empty apOnline}">${apOnline} online · ${apOffline} offline</c:when>
                                <c:otherwise>Loading...</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
            <div class="bento-card bento-card-half">
                <div class="bento-header">
                    <span class="bento-icon bento-icon-blue"><i class="bi bi-hdd-network"></i></span>
                    <span class="bento-label">Switches</span>
                </div>
                <div class="bento-value bento-value-blue">
                    <c:choose>
                        <c:when test="${not empty switchTotal}">${switchTotal}</c:when>
                        <c:otherwise>--</c:otherwise>
                    </c:choose>
                </div>
                <div class="bento-detail">
                    <c:choose>
                        <c:when test="${not empty switchOnline}">${switchOnline} online · ${switchMaint} maintenance</c:when>
                        <c:otherwise>Loading...</c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="bento-card bento-card-half">
                <div class="bento-header">
                    <span class="bento-icon bento-icon-pink"><i class="bi bi-laptop"></i></span>
                    <span class="bento-label">Devices</span>
                </div>
                <div class="bento-value bento-value-pink">
                    <c:choose>
                        <c:when test="${not empty deviceTotal}">${deviceTotal}</c:when>
                        <c:otherwise>--</c:otherwise>
                    </c:choose>
                </div>
                <div class="bento-detail">
                    <c:choose>
                        <c:when test="${not empty deviceAllowed}">${deviceAllowed} allowed · ${deviceBlocked} blocked</c:when>
                        <c:otherwise>Loading...</c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="bento-card bento-card-half">
                <div class="bento-header">
                    <span class="bento-icon bento-icon-danger"><i class="bi bi-exclamation-triangle"></i></span>
                    <span class="bento-label">Alerts</span>
                </div>
                <div class="bento-value bento-value-danger">
                    <c:choose>
                        <c:when test="${not empty alertTotal}">${alertTotal}</c:when>
                        <c:otherwise>--</c:otherwise>
                    </c:choose>
                </div>
                <div class="bento-detail">
                    <c:choose>
                        <c:when test="${not empty alertCritical}">${alertCritical} critical · ${alertWarning} warnings</c:when>
                        <c:otherwise>Loading...</c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="bento-card bento-card-half">
                <div class="bento-header">
                    <span class="bento-icon bento-icon-blue"><i class="bi bi-people"></i></span>
                    <span class="bento-label">Users</span>
                </div>
                <div class="bento-value bento-value-blue">
                    <c:choose>
                        <c:when test="${not empty userTotal}">${userTotal}</c:when>
                        <c:otherwise>--</c:otherwise>
                    </c:choose>
                </div>
                <div class="bento-detail">Registered platform accounts</div>
            </div>
        </div>
    </div>
</section>

<section id="features" style="background: rgba(255,255,255,0.01);">
    <div class="container-narrow">
        <div class="reveal" style="text-align:center;margin-bottom:60px;">
            <span class="section-label">Platform Capabilities</span>
            <h2 class="section-title" style="text-align:center;max-width:600px;margin-left:auto;margin-right:auto;">
                Everything you need to manage your network
            </h2>
            <p class="section-desc" style="text-align:center;margin-left:auto;margin-right:auto;">
                From real-time monitoring to maintenance scheduling — a complete toolkit for network administrators.
            </p>
        </div>

        <div class="features-grid">
            <div class="feature-row reveal reveal-delay-1">
                <div class="feature-text">
                    <span class="feature-tag feature-tag-purple">Real-time</span>
                    <h3>Live device monitoring</h3>
                    <p>
                        Track routers, access points, switches, and network devices in real time.
                        View IP addresses, MAC addresses, connection status, and room assignments at a glance.
                    </p>
                    <a href="login.jsp" class="feature-link">
                        Explore monitoring <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
                <div class="feature-visual">
                    <div class="feature-mock">
                        <div class="feature-mock-header">
                            <span class="feature-mock-dot" style="background:#ef4444;"></span>
                            <span class="feature-mock-dot" style="background:var(--neon-blue);"></span>
                            <span class="feature-mock-dot" style="background:var(--neon-pink);"></span>
                            <span style="margin-left:8px;font-size:11px;color:var(--text-muted);">Device Status</span>
                        </div>
                        <div class="feature-mock-content">
                            <div style="display:flex;justify-content:space-between;font-size:11px;">
                                <span style="color:var(--neon-purple);">Routers</span>
                                <span style="color:var(--text-muted);">
                                    <c:choose>
                                        <c:when test="${not empty routerOnline}">${routerOnline}/${routerTotal}</c:when>
                                        <c:otherwise>--/--</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="feature-mock-bar">
                                <c:choose>
                                    <c:when test="${not empty routerTotal && routerTotal > 0}">
                                        <div class="feature-mock-bar-fill" style="width:${routerOnline * 100 / routerTotal}%;"></div>
                                    </c:when>
                                    <c:otherwise><div class="feature-mock-bar-fill" style="width:0%;"></div></c:otherwise>
                                </c:choose>
                            </div>
                            <div style="display:flex;justify-content:space-between;font-size:11px;margin-top:6px;">
                                <span style="color:var(--neon-pink);">Access Points</span>
                                <span style="color:var(--text-muted);">
                                    <c:choose>
                                        <c:when test="${not empty apOnline}">${apOnline}/${apTotal}</c:when>
                                        <c:otherwise>--/--</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="feature-mock-bar">
                                <c:choose>
                                    <c:when test="${not empty apTotal && apTotal > 0}">
                                        <div class="feature-mock-bar-fill pink" style="width:${apOnline * 100 / apTotal}%;"></div>
                                    </c:when>
                                    <c:otherwise><div class="feature-mock-bar-fill pink" style="width:0%;"></div></c:otherwise>
                                </c:choose>
                            </div>
                            <div style="display:flex;justify-content:space-between;font-size:11px;margin-top:6px;">
                                <span style="color:var(--neon-blue);">Switches</span>
                                <span style="color:var(--text-muted);">
                                    <c:choose>
                                        <c:when test="${not empty switchOnline}">${switchOnline}/${switchTotal}</c:when>
                                        <c:otherwise>--/--</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="feature-mock-bar">
                                <c:choose>
                                    <c:when test="${not empty switchTotal && switchTotal > 0}">
                                        <div class="feature-mock-bar-fill blue" style="width:${switchOnline * 100 / switchTotal}%;"></div>
                                    </c:when>
                                    <c:otherwise><div class="feature-mock-bar-fill blue" style="width:0%;"></div></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="feature-row reveal reveal-delay-2">
                <div class="feature-text">
                    <span class="feature-tag feature-tag-pink">Intelligence</span>
                    <h3>Bandwidth & analytics</h3>
                    <p>
                        Monitor bandwidth usage across devices, track upload and download speeds,
                        and identify performance bottlenecks before they impact users.
                    </p>
                    <a href="login.jsp" class="feature-link">
                        View analytics <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
                <div class="feature-visual">
                    <div class="feature-mock">
                        <div class="feature-mock-header">
                            <span class="feature-mock-dot" style="background:var(--neon-pink);"></span>
                            <span style="margin-left:6px;font-size:11px;color:var(--text-muted);">Bandwidth Usage</span>
                        </div>
                        <div class="feature-mock-content">
                            <div style="font-size:28px;font-weight:800;color:var(--neon-pink);">74 <span style="font-size:14px;color:var(--text-muted);">Mbps</span></div>
                            <div style="font-size:11px;color:var(--text-muted);">Current utilization &middot; 100 Mbps capacity</div>
                            <div class="feature-mock-bar" style="margin-top:6px;">
                                <div class="feature-mock-bar-fill pink" style="width:74%;"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="feature-row reveal reveal-delay-3">
                <div class="feature-text">
                    <span class="feature-tag feature-tag-blue">Scheduling</span>
                    <h3>Maintenance & alerts</h3>
                    <p>
                        Schedule maintenance windows for routers, access points, and switches.
                        Receive instant alerts when devices go offline or performance degrades.
                    </p>
                    <a href="login.jsp" class="feature-link">
                        Set up alerts <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
                <div class="feature-visual">
                    <div class="feature-mock">
                        <div class="feature-mock-header">
                            <span class="feature-mock-dot" style="background:var(--neon-blue);"></span>
                            <span style="margin-left:6px;font-size:11px;color:var(--text-muted);">Alert Timeline</span>
                        </div>
                        <div class="feature-mock-content">
                            <div style="display:flex;align-items:center;gap:10px;">
                                <span class="severity-dot severity-critical"></span>
                                <div>
                                    <div style="font-size:12px;font-weight:600;">AP-Floor2 went offline</div>
                                    <div style="font-size:10px;color:var(--text-muted);">CRITICAL &middot; just now</div>
                                </div>
                            </div>
                            <div style="display:flex;align-items:center;gap:10px;margin-top:6px;">
                                <span class="severity-dot severity-warning"></span>
                                <div>
                                    <div style="font-size:12px;font-weight:600;">High bandwidth on Switch-A1</div>
                                    <div style="font-size:10px;color:var(--text-muted);">WARNING &middot; 5m ago</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<section id="how-it-works" style="background: rgba(255,255,255,0.01);">
    <div class="container-narrow">
        <div class="reveal" style="text-align:center;margin-bottom:48px;">
            <span class="section-label">Workflow</span>
            <h2 class="section-title" style="text-align:center;max-width:500px;margin-left:auto;margin-right:auto;">
                How it works
            </h2>
            <p class="section-desc" style="text-align:center;margin-left:auto;margin-right:auto;">
                Get your network under control in three simple steps.
            </p>
        </div>
        <div class="steps-grid reveal reveal-delay-1">
            <div class="step-card">
                <div class="step-number">1</div>
                <h4>Connect your devices</h4>
                <p>Add routers, access points, switches, and other network equipment to the system with IP and location details.</p>
            </div>
            <div class="step-card">
                <div class="step-number">2</div>
                <h4>Monitor in real time</h4>
                <p>Track device status, bandwidth usage, and connected clients. Get instant visibility into your entire network.</p>
            </div>
            <div class="step-card">
                <div class="step-number">3</div>
                <h4>Respond to alerts</h4>
                <p>Receive notifications when devices go offline or traffic spikes. Schedule maintenance before issues escalate.</p>
            </div>
        </div>
    </div>
</section>

<section id="alerts">
    <div class="container-narrow">
        <div class="reveal">
            <span class="section-label">Live Feed</span>
            <h2 class="section-title">Recent network alerts</h2>
            <p class="section-desc">Stay informed about critical events across your network infrastructure.</p>
        </div>

        <div class="reveal reveal-delay-1" style="display:flex;gap:12px;flex-wrap:wrap;margin-bottom:24px;">
            <div style="display:flex;align-items:center;gap:8px;padding:10px 16px;border-radius:var(--radius-md);border:1px solid rgba(255,255,255,0.06);background:rgba(14,20,36,0.5);font-size:13px;">
                <span style="width:8px;height:8px;border-radius:50%;background:var(--neon-pink);box-shadow:0 0 8px rgba(217,70,239,0.5);"></span>
                <span>System</span>
                <span style="color:var(--text-muted);font-weight:600;">
                    <c:choose>
                        <c:when test="${not empty routerOnline && not empty apOnline && not empty switchOnline}">
                            ${routerOnline + apOnline + switchOnline} devices online
                        </c:when>
                        <c:otherwise>Loading...</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div style="display:flex;align-items:center;gap:8px;padding:10px 16px;border-radius:var(--radius-md);border:1px solid rgba(255,255,255,0.06);background:rgba(14,20,36,0.5);font-size:13px;">
                <span style="width:8px;height:8px;border-radius:50%;background:var(--neon-purple);box-shadow:0 0 8px rgba(139,92,246,0.5);"></span>
                <span>Alerts</span>
                <span style="color:var(--text-muted);font-weight:600;">
                    <c:choose>
                        <c:when test="${not empty alertTotal}">${alertTotal} total</c:when>
                        <c:otherwise>--</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div style="display:flex;align-items:center;gap:8px;padding:10px 16px;border-radius:var(--radius-md);border:1px solid rgba(255,255,255,0.06);background:rgba(14,20,36,0.5);font-size:13px;">
                <span style="width:8px;height:8px;border-radius:50%;background:var(--danger);box-shadow:0 0 8px rgba(239,68,68,0.5);"></span>
                <span>Critical</span>
                <span style="color:var(--text-muted);font-weight:600;">
                    <c:choose>
                        <c:when test="${not empty alertCritical}">${alertCritical}</c:when>
                        <c:otherwise>--</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div style="display:flex;align-items:center;gap:8px;padding:10px 16px;border-radius:var(--radius-md);border:1px solid rgba(255,255,255,0.06);background:rgba(14,20,36,0.5);font-size:13px;">
                <span style="width:8px;height:8px;border-radius:50%;background:var(--neon-blue);box-shadow:0 0 8px rgba(96,165,250,0.5);"></span>
                <span>Warnings</span>
                <span style="color:var(--text-muted);font-weight:600;">
                    <c:choose>
                        <c:when test="${not empty alertWarning}">${alertWarning}</c:when>
                        <c:otherwise>--</c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>

        <div class="bento-card reveal reveal-delay-2" style="padding:0;max-width:700px;">
            <div class="alerts-list">
                <c:choose>
                    <c:when test="${not empty recentAlerts && not empty recentAlerts[0]}">
                        <c:forEach var="alert" items="${recentAlerts}">
                            <div class="alert-row">
                                <span class="severity-dot severity-${fn:toLowerCase(alert.severity)}"></span>
                                <div class="alert-content">
                                    <div class="alert-message">
                                        <c:out value="${alert.message}" />
                                    </div>
                                    <div class="alert-meta">
                                        <c:out value="${alert.severity}" />
                                        <c:if test="${not empty alert.createdAt}">
                                            &middot; <fmt:formatDate value="${alert.createdAt}" pattern="yyyy-MM-dd HH:mm" />
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="alert-empty">
                            <i class="bi bi-check-circle" style="font-size:28px;color:var(--neon-pink);display:block;margin-bottom:8px;"></i>
                            No recent alerts. Your network is healthy.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</section>

<section class="cta-section">
    <div class="cta-box reveal">
        <h2 class="cta-title">Ready to take control?</h2>
        <p class="cta-desc">
            Sign in to access the full dashboard or create an account to get started in minutes.
        </p>
        <div class="cta-actions">
            <a href="login.jsp" class="btn-primary">
                <span>Sign In</span>
                <span class="btn-icon"><i class="bi bi-arrow-right"></i></span>
            </a>
            <a href="user-form.jsp?source=normal" class="btn-secondary">
                <i class="bi bi-person-plus"></i> Create Account
            </a>
        </div>
    </div>
</section>

<footer class="footer">
    <div class="footer-inner">
        <span class="footer-brand">
            <span class="nav-logo-icon" style="width:24px;height:24px;font-size:12px;"><i class="bi bi-shield-shaded"></i></span>
            NetGuard
        </span>
        <span class="footer-copy">University Network Management System &copy; 2026</span>
    </div>
</footer>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const observer = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                }
            });
        }, { threshold: 0.08 });

        document.querySelectorAll('.reveal').forEach(function (el) {
            observer.observe(el);
        });

        document.querySelectorAll('.nav-links a').forEach(function (link) {
            link.addEventListener('click', function () {
                document.querySelectorAll('.nav-links a').forEach(function (l) {
                    l.classList.remove('active');
                });
                this.classList.add('active');
            });
        });
    });

    window.addEventListener('scroll', function () {
        var nav = document.querySelector('.nav-island');
        if (window.scrollY > 100) {
            nav.style.transform = 'translateX(-50%) scale(0.96)';
            nav.style.boxShadow = '0 16px 56px rgba(0,0,0,0.6)';
        } else {
            nav.style.transform = 'translateX(-50%) scale(1)';
            nav.style.boxShadow = '0 12px 48px rgba(0,0,0,0.5)';
        }
    });

    document.querySelectorAll('a[href^="#"]').forEach(function (anchor) {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            var target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    });
</script>
</body>
</html>
