import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import gzip

sns.set(color_codes=True)
sns.set_palette(sns.color_palette("colorblind"))
sns.set_style("white")


def roc_plots(axes, csv_files, labels, title, line_types, alphas, colors):
    rocs = list()
    count = 0
    for csv_gz in csv_files:
        with gzip.open(csv_gz) as csv_file:
            df = pd.read_csv(csv_file)
            df = df.sort_values(['METRIC.Recall'], ascending=False)

            sensitivity = list(df['METRIC.Recall'])
            precision = list(df['METRIC.Precision'])
            # for i in range(len(sensitivity)):
                # if i > 0 and precision[i] < precision[i-1]:
                #     print("HERE:", QQ[i], '\t', precision[i], '\t', sensitivity[i])
                # print(QQ[i], '\t', precision[i], '\t', sensitivity[i])
            # print(sensitivity)
            # print(precision)
            # exit()

            filtered_precision = []
            filtered_recall = []
            for i in range(len(precision)):
                if sensitivity[i] > 0:
                    filtered_precision.append(precision[i])
                    filtered_recall.append(sensitivity[i])
            precision = filtered_precision
            sensitivity = filtered_recall

            # fdr = [precision[i] for i in range(len(precision))]
            #
            # last_sensitivity = sensitivity[len(sensitivity)-1]
            # last_fdr = fdr[len(fdr)-1]
            # sensitivity.append(last_sensitivity)
            # fdr.append(last_fdr)
            roc, = axes.plot(sensitivity, precision, linestyle=line_types[count], alpha=alphas[count], linewidth=2, color=colors[count])
            rocs.append(roc)
            count += 1

        leg = axes.legend(rocs, labels, frameon=True, framealpha=1, borderpad=1, fontsize=15)
        leg.get_frame().set_edgecolor('black')
        axes.set_xlabel('Recall')
        axes.set_ylabel('Precision', fontsize=8)
        # axes.set_ylim(0.3, 1.00)
        axes.set_title(title, fontweight='bold')


def generate_plot():
    fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(12, 6), sharey=False)
    # --------------------------------- SNP --------------------------------- #
    current_title = "SNP"
    line_types = [':', '--']
    colors = ['red', 'blue']
    alphas = [0.7, 0.7]
    snp_csv_files = ['/data/users/kishwar/new_paper_results/friday_evals/happy_output/pfda_HG002_GRCh37/friday_hg002_grch37.roc.Locations.SNP.csv.gz',
                     '/data/users/kishwar/new_paper_results/deepvariant_evals/happy_output/pfda_hg002_grch37/deepvariant_hg002_grch37.roc.Locations.SNP.csv.gz']
    snp_labels = ['$FRIDAY$', '$DeepVariant$']

    roc_plots(axes[0], snp_csv_files, snp_labels, current_title, line_types, alphas, colors)

    # --------------------------------- INDEL --------------------------------- #
    current_title = "INDEL"
    indel_csv_files = ['/data/users/kishwar/new_paper_results/friday_evals/happy_output/pfda_HG002_GRCh37/friday_hg002_grch37.roc.Locations.INDEL.csv.gz',
                       '/data/users/kishwar/new_paper_results/deepvariant_evals/happy_output/pfda_hg002_grch37/deepvariant_hg002_grch37.roc.Locations.INDEL.csv.gz']
    indel_labels = ['$FRIDAY$', '$DeepVariant$']
    roc_plots(axes[1], indel_csv_files, indel_labels, current_title, line_types, alphas, colors)

    fig.tight_layout()
    # fig.subplots_adjust(top=0.1, bottom=0.0)
    # fig.suptitle("Precision-Recall Curve", fontsize=14)
    # plt.show()
    plt.savefig('PR_plot.pdf', dpi=1600, format='pdf')


if __name__ == '__main__':
    generate_plot()
