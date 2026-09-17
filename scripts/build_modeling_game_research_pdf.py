from __future__ import annotations

import html
import re
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate,
    Frame,
    KeepTogether,
    PageTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs" / "modeling-game-research" / "report-source.md"
OUTPUT = ROOT / "output" / "pdf" / "before_waking_modeling_game_research_zh.pdf"

TEAL = colors.HexColor("#0A5961")
DEEP = colors.HexColor("#17323A")
AMBER = colors.HexColor("#D88A2D")
PALE = colors.HexColor("#E8F1F0")
INK = colors.HexColor("#24343A")
MUTED = colors.HexColor("#68777C")
LINE = colors.HexColor("#B9C9CB")
PAPER = colors.HexColor("#FBFAF6")


def register_fonts() -> None:
    pdfmetrics.registerFont(TTFont("Deng", r"C:\Windows\Fonts\Deng.ttf"))
    pdfmetrics.registerFont(TTFont("Deng-Bold", r"C:\Windows\Fonts\Dengb.ttf"))
    pdfmetrics.registerFontFamily("Deng", normal="Deng", bold="Deng-Bold")


def markup(text: str) -> str:
    escaped = html.escape(text.strip())
    escaped = re.sub(
        r"\[([^\]]+)\]\((https?://[^)]+)\)",
        lambda m: f'<link href="{html.unescape(m.group(2))}" color="#0A5961"><u>{m.group(1)}</u></link>',
        escaped,
    )
    escaped = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", escaped)
    escaped = re.sub(r"`([^`]+)`", r'<font color="#8A5520">\1</font>', escaped)
    escaped = escaped.replace("  ", " ")
    return escaped


def styles():
    base = getSampleStyleSheet()
    return {
        "title": ParagraphStyle(
            "TitleCN", parent=base["Title"], fontName="Deng-Bold", fontSize=25,
            leading=31, textColor=DEEP, alignment=TA_CENTER, spaceAfter=10 * mm,
        ),
        "subtitle": ParagraphStyle(
            "SubtitleCN", parent=base["Heading2"], fontName="Deng", fontSize=13.5,
            leading=20, textColor=TEAL, alignment=TA_CENTER, spaceAfter=10 * mm,
        ),
        "h2": ParagraphStyle(
            "H2CN", parent=base["Heading2"], fontName="Deng-Bold", fontSize=16,
            leading=22, textColor=DEEP, spaceBefore=8 * mm, spaceAfter=3.5 * mm,
            keepWithNext=True,
        ),
        "h3": ParagraphStyle(
            "H3CN", parent=base["Heading3"], fontName="Deng-Bold", fontSize=12.5,
            leading=18, textColor=TEAL, spaceBefore=5 * mm, spaceAfter=2 * mm,
            keepWithNext=True,
        ),
        "body": ParagraphStyle(
            "BodyCN", parent=base["BodyText"], fontName="Deng", fontSize=9.6,
            leading=15.3, textColor=INK, spaceAfter=2.5 * mm,
        ),
        "meta": ParagraphStyle(
            "MetaCN", parent=base["BodyText"], fontName="Deng", fontSize=9,
            leading=14, textColor=MUTED, alignment=TA_CENTER, spaceAfter=1.5 * mm,
        ),
        "quote": ParagraphStyle(
            "QuoteCN", parent=base["BodyText"], fontName="Deng-Bold", fontSize=11,
            leading=18, textColor=TEAL, leftIndent=8 * mm, rightIndent=8 * mm,
            borderColor=AMBER, borderWidth=1.2, borderPadding=5 * mm,
            backColor=colors.HexColor("#FFF6E8"), spaceBefore=4 * mm, spaceAfter=5 * mm,
        ),
        "bullet": ParagraphStyle(
            "BulletCN", parent=base["BodyText"], fontName="Deng", fontSize=9.4,
            leading=14.8, textColor=INK, leftIndent=6 * mm, firstLineIndent=-3.5 * mm,
            spaceAfter=1.7 * mm,
        ),
        "code": ParagraphStyle(
            "CodeCN", parent=base["Code"], fontName="Deng", fontSize=9,
            leading=14, textColor=DEEP, leftIndent=6 * mm, rightIndent=6 * mm,
            borderColor=LINE, borderWidth=0.6, borderPadding=3 * mm,
            backColor=PALE, spaceBefore=2 * mm, spaceAfter=4 * mm,
        ),
        "table": ParagraphStyle(
            "TableCN", parent=base["BodyText"], fontName="Deng", fontSize=7.8,
            leading=11.2, textColor=INK,
        ),
        "table_head": ParagraphStyle(
            "TableHeadCN", parent=base["BodyText"], fontName="Deng-Bold", fontSize=8,
            leading=11.5, textColor=colors.white,
        ),
    }


def parse_table(lines: list[str], sty: dict, usable_width: float):
    rows = []
    for line in lines:
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if all(re.fullmatch(r":?-{3,}:?", c.replace(" ", "")) for c in cells):
            continue
        rows.append(cells)
    if not rows:
        return Spacer(1, 1)
    cols = max(len(r) for r in rows)
    normalized = [r + [""] * (cols - len(r)) for r in rows]
    data = []
    for ridx, row in enumerate(normalized):
        style = sty["table_head"] if ridx == 0 else sty["table"]
        data.append([Paragraph(markup(c), style) for c in row])

    if cols == 4:
        widths = [usable_width * 0.17, usable_width * 0.21, usable_width * 0.27, usable_width * 0.35]
    elif cols == 3:
        widths = [usable_width * 0.25, usable_width * 0.48, usable_width * 0.27]
    else:
        widths = [usable_width / cols] * cols
    table = Table(data, colWidths=widths, repeatRows=1, hAlign="LEFT")
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), TEAL),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("GRID", (0, 0), (-1, -1), 0.35, LINE),
        ("LEFTPADDING", (0, 0), (-1, -1), 5),
        ("RIGHTPADDING", (0, 0), (-1, -1), 5),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, PALE]),
    ]))
    return table


def markdown_story(text: str, sty: dict, usable_width: float):
    story = []
    lines = text.splitlines()
    i = 0
    first_h1 = True
    meta_mode = True
    while i < len(lines):
        raw = lines[i]
        line = raw.strip()
        if not line:
            i += 1
            continue
        if line.startswith("```"):
            code = []
            i += 1
            while i < len(lines) and not lines[i].strip().startswith("```"):
                code.append(html.escape(lines[i]).replace(" ", "&nbsp;"))
                i += 1
            story.append(Paragraph("<br/>".join(code), sty["code"]))
            i += 1
            continue
        if line.startswith("|"):
            block = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                block.append(lines[i])
                i += 1
            story.append(parse_table(block, sty, usable_width))
            story.append(Spacer(1, 3 * mm))
            continue
        if line.startswith("# "):
            story.append(Spacer(1, 18 * mm if first_h1 else 4 * mm))
            story.append(Paragraph(markup(line[2:]), sty["title"]))
            first_h1 = False
            i += 1
            continue
        if line.startswith("## "):
            content = line[3:]
            if meta_mode and not content.startswith(("一、", "二、", "三、", "四、", "五、", "六、", "七、", "八、", "主要")):
                story.append(Paragraph(markup(content), sty["subtitle"]))
            else:
                meta_mode = False
                story.append(Paragraph(markup(content), sty["h2"]))
            i += 1
            continue
        if line.startswith("### "):
            story.append(Paragraph(markup(line[4:]), sty["h3"]))
            i += 1
            continue
        if line.startswith("> "):
            story.append(Paragraph(markup(line[2:]), sty["quote"]))
            i += 1
            continue
        if re.match(r"^[-*] ", line):
            story.append(Paragraph("• " + markup(line[2:]), sty["bullet"]))
            i += 1
            continue
        if re.match(r"^\d+\. ", line):
            number, content = line.split(". ", 1)
            story.append(Paragraph(f"{number}. " + markup(content), sty["bullet"]))
            i += 1
            continue
        if meta_mode and line.startswith("**"):
            story.append(Paragraph(markup(line.replace("  ", " ")), sty["meta"]))
            i += 1
            continue

        paragraph = [line]
        i += 1
        while i < len(lines):
            nxt = lines[i].strip()
            if not nxt or nxt.startswith(("#", ">", "|", "```", "- ", "* ")) or re.match(r"^\d+\. ", nxt):
                break
            paragraph.append(nxt)
            i += 1
        story.append(Paragraph(markup(" ".join(paragraph)), sty["body"]))
    return story


class ReportDoc(BaseDocTemplate):
    pass


def header_footer(canvas, doc):
    canvas.saveState()
    width, height = A4
    if doc.page > 1:
        canvas.setStrokeColor(LINE)
        canvas.setLineWidth(0.45)
        canvas.line(18 * mm, height - 14 * mm, width - 18 * mm, height - 14 * mm)
        canvas.setFont("Deng", 7.5)
        canvas.setFillColor(MUTED)
        canvas.drawString(18 * mm, height - 11 * mm, "醒来之前：建模质量与游戏设计")
        canvas.drawRightString(width - 18 * mm, 10 * mm, f"{doc.page}")
    canvas.restoreState()


def build() -> None:
    register_fonts()
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    sty = styles()
    left = right = 18 * mm
    top = 19 * mm
    bottom = 16 * mm
    usable_width = A4[0] - left - right
    frame = Frame(left, bottom, usable_width, A4[1] - top - bottom, id="main")
    doc = ReportDoc(
        str(OUTPUT), pagesize=A4, leftMargin=left, rightMargin=right,
        topMargin=top, bottomMargin=bottom,
        title="醒来之前：建模质量与游戏设计",
        author="Codex research synthesis",
        subject="建模、GitHub skills、具身交互与叙事游戏",
    )
    doc.addPageTemplates([PageTemplate(id="report", frames=[frame], onPage=header_footer)])
    story = markdown_story(SOURCE.read_text(encoding="utf-8"), sty, usable_width)
    doc.build(story)
    print(OUTPUT)


if __name__ == "__main__":
    build()
