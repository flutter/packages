#!/usr/bin/env python3
"""
analyze_prose.py - Statistical analysis and anti-AI-ism compliance scanner for text/markdown documents.
"""

import sys
import os
import re
import json
import statistics

BANNED_WORDS = [
    "delve", "leverage", "foster", "cultivate", "maximize", "democratize",
    "resonate", "encompass", "bridge", "underscore", "utilize", "seamless",
    "seamlessly", "robust", "pivotal", "crucial", "vibrant", "intricate",
    "nuanced", "unwavering", "indelible", "uncharted", "transformative",
    "breathtaking", "nestled", "dynamic", "comprehensive", "intuitive",
    "holistic", "frictionless", "scalable", "synergistic", "tapestry",
    "landscape", "realm", "testament", "interplay", "synergy", "cornerstone"
]

def split_into_sentences(text):
    """Splits text into sentences while ignoring common abbreviations."""
    # Simple regex sentence splitting on .!? followed by whitespace
    raw_sentences = re.split(r'(?<=[.!?])\s+', text)
    cleaned = []
    for s in raw_sentences:
        s_strip = s.strip()
        # Ignore markdown headers, bullet points markers, or code fences
        if s_strip and not s_strip.startswith('#') and not s_strip.startswith('```') and not s_strip.startswith('|'):
            cleaned.append(s_strip)
    return cleaned

def analyze_prose(file_path):
    if not os.path.exists(file_path):
        return {"error": f"File not found: {file_path}"}

    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    full_text = "".join(lines)
    
    # Extract plain text paragraphs (ignoring headers, tables, code blocks)
    in_code_block = False
    paragraphs = []
    current_para = []

    for line in lines:
        line_str = line.strip()
        if line_str.startswith('```'):
            in_code_block = not in_code_block
            continue
        if in_code_block:
            continue
        if not line_str or line_str.startswith('#') or line_str.startswith('|'):
            if current_para:
                paragraphs.append("\n".join(current_para))
                current_para = []
            continue
        current_para.append(line_str)
    if current_para:
        paragraphs.append("\n".join(current_para))

    # All words in body
    words = re.findall(r'\b[a-zA-Z0-9_\'-]+\b', full_text)
    total_words = len(words)

    # Word lengths
    word_lengths = [len(w) for w in words] if words else [0]
    median_word_length = statistics.median(word_lengths) if word_lengths else 0

    # Sentences analysis
    sentences = split_into_sentences(full_text)
    total_sentences = len(sentences)

    sentence_word_counts = []
    long_sentences = []

    for idx, s in enumerate(sentences, 1):
        s_words = re.findall(r'\b[a-zA-Z0-9_\'-]+\b', s)
        w_count = len(s_words)
        if w_count > 0:
            sentence_word_counts.append(w_count)
        if w_count > 25:
            long_sentences.append({
                "index": idx,
                "word_count": w_count,
                "text": s[:100] + ("..." if len(s) > 100 else "")
            })

    median_words_per_sentence = statistics.median(sentence_word_counts) if sentence_word_counts else 0

    # Paragraph analysis
    para_sentence_counts = []
    para_word_counts = []
    long_paragraphs = []

    for idx, p in enumerate(paragraphs, 1):
        p_sentences = split_into_sentences(p)
        p_words = re.findall(r'\b[a-zA-Z0-9_\'-]+\b', p)
        num_s = len(p_sentences)
        num_w = len(p_words)

        para_sentence_counts.append(num_s)
        para_word_counts.append(num_w)

        if num_s > 4:
            long_paragraphs.append({
                "paragraph_index": idx,
                "sentence_count": num_s,
                "snippet": p[:80] + ("..." if len(p) > 80 else "")
            })

    median_sentences_per_para = statistics.median(para_sentence_counts) if para_sentence_counts else 0
    median_words_per_para = statistics.median(para_word_counts) if para_word_counts else 0

    # Banned words scanning with line numbers
    banned_matches = []
    for line_idx, line in enumerate(lines, 1):
        # Skip code blocks
        if line.strip().startswith('```') or line.strip().startswith('|'):
            continue
        line_words = re.findall(r'\b[a-zA-Z0-9_\'-]+\b', line.lower())
        for bw in BANNED_WORDS:
            if bw in line_words:
                banned_matches.append({
                    "line": line_idx,
                    "banned_word": bw,
                    "line_snippet": line.strip()[:90]
                })

    return {
        "file_path": file_path,
        "summary": {
            "total_words": total_words,
            "total_sentences": total_sentences,
            "total_paragraphs": len(paragraphs),
            "median_word_length_chars": round(median_word_length, 1),
            "median_words_per_sentence": round(median_words_per_sentence, 1),
            "median_sentences_per_paragraph": round(median_sentences_per_para, 1),
            "median_words_per_paragraph": round(median_words_per_para, 1)
        },
        "violations": {
            "banned_ai_words_found": banned_matches,
            "sentences_exceeding_25_words": long_sentences,
            "paragraphs_exceeding_4_sentences": long_paragraphs
        }
    }

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: analyze_prose.py <path-to-file>"}))
        sys.exit(1)

    target_file = sys.argv[1]
    result = analyze_prose(target_file)
    print(json.dumps(result, indent=2))
