#!/usr/bin/env python3
"""
STA Analysis Data Collection and Plotting Script
Collects data from all 4 simulation stages (synth, placement, cts, route)
Generates comprehensive plots: TNS, WNS, Worst Setup Slack, Worst Hold Slack
"""

import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path

# Base directory
base_dir = Path('/home/iraj/OpenROAD-flow-scripts/sta_output_week8')
stages = ['synth', 'placement', 'cts', 'route']

def read_timing_file(filepath):
    """Read timing report file and extract data"""
    data = {}
    try:
        with open(filepath, 'r') as f:
            for line in f:
                line = line.strip()
                if line:
                    parts = line.split()
                    if len(parts) >= 2:
                        lib_name = parts[0]
                        try:
                            value = float(parts[-1])
                            data[lib_name] = value
                        except ValueError:
                            continue
    except FileNotFoundError:
        print(f"Warning: File not found - {filepath}")
    return data

def collect_all_data():
    """Collect all timing data from all stages"""
    all_data = {}
    
    for stage in stages:
        stage_dir = base_dir / stage
        all_data[stage] = {}
        
        print(f"\nCollecting data from {stage}...")
        
        # Read all timing metrics
        worst_max_file = stage_dir / 'sta_worst_max_slack.txt'
        worst_min_file = stage_dir / 'sta_worst_min_slack.txt'
        tns_file = stage_dir / 'sta_tns.txt'
        wns_file = stage_dir / 'sta_wns.txt'
        
        all_data[stage]['worst_setup'] = read_timing_file(worst_max_file)
        all_data[stage]['worst_hold'] = read_timing_file(worst_min_file)
        all_data[stage]['tns'] = read_timing_file(tns_file)
        all_data[stage]['wns'] = read_timing_file(wns_file)
        
        print(f"  Loaded {len(all_data[stage]['worst_setup'])} corners")
    
    return all_data

def create_dataframe(all_data, metric):
    """Create DataFrame for a specific metric across all stages"""
    df = pd.DataFrame()
    
    for stage in stages:
        df[stage] = pd.Series(all_data[stage][metric])
    
    df = df.sort_index()
    return df

def plot_metric_3d(df, metric_name, output_file):
    """Create a 3D-like bar plot for a timing metric"""
    fig, ax = plt.subplots(figsize=(14, 8))
    
    corners = df.index
    x = np.arange(len(corners))
    width = 0.2
    
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A']
    
    for i, stage in enumerate(stages):
        offset = (i - 1.5) * width
        ax.bar(x + offset, df[stage], width, label=stage.upper(), color=colors[i], alpha=0.8)
    
    ax.set_xlabel('Library Corner', fontsize=12, fontweight='bold')
    ax.set_ylabel('Timing (ns)', fontsize=12, fontweight='bold')
    ax.set_title(f'{metric_name} Across All Stages and Corners', fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(corners, rotation=45, ha='right', fontsize=9)
    ax.legend(loc='best', fontsize=11)
    ax.grid(axis='y', alpha=0.3)
    ax.axhline(y=0, color='black', linestyle='-', linewidth=0.8)
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"✓ Saved: {output_file}")
    plt.close()

def plot_combined_metrics(all_data, output_file):
    """Create combined plot showing all metrics for all stages"""
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    
    metrics = [
        ('tns', 'Total Negative Slack (TNS)', axes[0, 0]),
        ('wns', 'Worst Negative Slack (WNS)', axes[0, 1]),
        ('worst_setup', 'Worst Setup Slack', axes[1, 0]),
        ('worst_hold', 'Worst Hold Slack', axes[1, 1])
    ]
    
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A']
    
    for metric, title, ax in metrics:
        df = create_dataframe(all_data, metric)
        corners = df.index
        x = np.arange(len(corners))
        width = 0.2
        
        for i, stage in enumerate(stages):
            offset = (i - 1.5) * width
            ax.bar(x + offset, df[stage], width, label=stage.upper(), color=colors[i], alpha=0.8)
        
        ax.set_xlabel('Library Corner', fontsize=10, fontweight='bold')
        ax.set_ylabel('Timing (ns)', fontsize=10, fontweight='bold')
        ax.set_title(title, fontsize=11, fontweight='bold')
        ax.set_xticks(x)
        ax.set_xticklabels(corners, rotation=45, ha='right', fontsize=8)
        ax.legend(loc='best', fontsize=9)
        ax.grid(axis='y', alpha=0.3)
        ax.axhline(y=0, color='black', linestyle='-', linewidth=0.8)
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"✓ Saved: {output_file}")
    plt.close()

def save_to_csv(all_data, csv_file):
    """Save all data to CSV file"""
    # Create combined dataframe
    rows = []
    
    # Get all corners from one stage
    sample_corners = list(all_data['synth']['tns'].keys())
    
    for corner in sample_corners:
        row = {'Library_Corner': corner}
        
        for stage in stages:
            row[f'{stage}_TNS'] = all_data[stage]['tns'].get(corner, np.nan)
            row[f'{stage}_WNS'] = all_data[stage]['wns'].get(corner, np.nan)
            row[f'{stage}_Worst_Setup_Slack'] = all_data[stage]['worst_setup'].get(corner, np.nan)
            row[f'{stage}_Worst_Hold_Slack'] = all_data[stage]['worst_hold'].get(corner, np.nan)
        
        rows.append(row)
    
    df = pd.DataFrame(rows)
    df.to_csv(csv_file, index=False)
    print(f"✓ CSV saved: {csv_file}")
    print(f"  Shape: {df.shape}")
    return df

def main():
    print("="*80)
    print("STA ANALYSIS DATA COLLECTION AND PLOTTING")
    print("="*80)
    
    # Collect all data
    all_data = collect_all_data()
    
    # Create output directory for plots
    plot_dir = base_dir / 'plots'
    plot_dir.mkdir(exist_ok=True)
    
    csv_file = plot_dir / 'sta_analysis_all_corners.csv'
    
    # Save to CSV
    print("\nSaving data to CSV...")
    df = save_to_csv(all_data, csv_file)
    print("\nCSV Preview:")
    print(df.head(10))
    
    # Create individual plots
    print("\nGenerating plots...")
    
    metrics = [
        ('tns', 'Total Negative Slack (TNS)', 'TNS_all_stages.png'),
        ('wns', 'Worst Negative Slack (WNS)', 'WNS_all_stages.png'),
        ('worst_setup', 'Worst Setup Slack', 'Worst_Setup_Slack_all_stages.png'),
        ('worst_hold', 'Worst Hold Slack', 'Worst_Hold_Slack_all_stages.png')
    ]
    
    for metric, title, filename in metrics:
        df = create_dataframe(all_data, metric)
        plot_metric_3d(df, title, plot_dir / filename)
    
    # Create combined plot
    print("\nGenerating combined 4-plot figure...")
    plot_combined_metrics(all_data, plot_dir / 'Combined_All_Metrics.png')
    
    print("\n" + "="*80)
    print("ANALYSIS COMPLETE")
    print("="*80)
    print(f"\nAll plots saved to: {plot_dir}")
    print("\nGenerated files:")
    for f in sorted(plot_dir.glob('*.png')):
        print(f"  - {f.name}")
    print(f"  - sta_analysis_all_corners.csv")

if __name__ == '__main__':
    main()
