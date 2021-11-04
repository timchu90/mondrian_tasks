version 1.0


task MarkDuplicates{
    input{
        File input_bam
        String? singularity_dir
        String filename_prefix = "output"
    }
    command{
        picard -Xmx12G -Xms12G MarkDuplicates \
        INPUT=~{input_bam} \
        OUTPUT=markdups.bam \
        METRICS_FILE=~{filename_prefix}_markduplicates_metrics.txt \
        REMOVE_DUPLICATES=False \
        ASSUME_SORTED=True \
        VALIDATION_STRINGENCY=LENIENT \
        TMP_DIR=tempdir \
        MAX_RECORDS_IN_RAM=150000
        samtools index markdups.bam
    }

    output{
        File output_bam = 'markdups.bam'
        File output_bai = 'markdups.bam.bai'
        File metrics_txt = '~{filename_prefix}_markduplicates_metrics.txt'
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.6'
        singularity: '~{singularity_dir}/alignment_v0.0.6.sif'
    }
}


task CollectGcBiasMetrics{
    input{
        File input_bam
        File reference
        File reference_fai
        String? singularity_dir
        String filename_prefix = "output"
    }
    command<<<
        picard -Xmx12G -Xms12G CollectGcBiasMetrics \
        INPUT=~{input_bam} \
        OUTPUT=~{filename_prefix}_gcbias_metrics.txt \
        S=summary.txt \
        CHART_OUTPUT=~{filename_prefix}_gcbias_chart.pdf \
        REFERENCE_SEQUENCE=~{reference} \
        VALIDATION_STRINGENCY=LENIENT \
        TMP_DIR=tempdir \
        MAX_RECORDS_IN_RAM=150000
    >>>
    output{
        File metrics_txt="~{filename_prefix}_gcbias_metrics.txt"
        File chart_pdf="~{filename_prefix}_gcbias_chart.pdf"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.6'
        singularity: '~{singularity_dir}/alignment_v0.0.6.sif'
    }
}


task CollectWgsMetrics{
    input{
        File input_bam
        File reference
        File reference_fai
        String? singularity_dir
        String filename_prefix = "output"
    }
    command<<<
        picard -Xmx12G -Xms12G CollectWgsMetrics \
        INPUT=~{input_bam} \
        OUTPUT=~{filename_prefix}_wgsmetrics.txt \
        REFERENCE_SEQUENCE=~{reference} \
        MINIMUM_BASE_QUALITY=0 \
        MINIMUM_MAPPING_QUALITY=0 \
        COVERAGE_CAP=500 \
        COUNT_UNPAIRED=False
        VALIDATION_STRINGENCY=LENIENT \
        MAX_RECORDS_IN_RAM=150000
    >>>
    output{
        File metrics_txt="~{filename_prefix}_wgsmetrics.txt"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.6'
        singularity: '~{singularity_dir}/alignment_v0.0.6.sif'
    }
}



task CollectInsertSizeMetrics{
    input{
        File input_bam
        String? singularity_dir
        String filename_prefix = "output"
    }
    command<<<
        picard -Xmx12G -Xms12G CollectInsertSizeMetrics \
        INPUT=~{input_bam} \
        OUTPUT=~{filename_prefix}_insert_metrics.txt \
        HISTOGRAM_FILE=~{filename_prefix}_insert_histogram.pdf \
        ASSUME_SORTED=True,
        VALIDATION_STRINGENCY=LENIENT \
        MAX_RECORDS_IN_RAM=150000
        TMP_DIR=tempdir

        if [ ! -f metrics.txt ]; then
            echo "## FAILED: No properly paired reads" >> ~{filename_prefix}_insert_metrics.txt
        fi

        if [ ! -f histogram.pdf ]; then
            touch ~{filename_prefix}_insert_histogram.pdf
        fi


    >>>
    output{
        File metrics_txt='~{filename_prefix}_insert_metrics.txt'
        File histogram_pdf='~{filename_prefix}_insert_histogram.pdf'
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.6'
        singularity: '~{singularity_dir}/alignment_v0.0.6.sif'
    }
}


task SortSam{
    input{
        File input_bam
        String? singularity_dir
    }
    command<<<
        picard -Xmx12G -Xms12G SortSam \
        INPUT=~{input_bam} \
        OUTPUT=markdups.bam \
        SORT_ORDER=coordinate \
        VALIDATION_STRINGENCY=LENIENT \
        MAX_RECORDS_IN_RAM=150000
        TMP_DIR=tempdir
    >>>
    output{
        File output_bam="markdups.bam"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.6'
        singularity: '~{singularity_dir}/alignment_v0.0.6.sif'
    }
}

task MergeSamFiles{
    input{
        Array[File] input_bams
        String? singularity_dir
    }
    command<<<
        picard -Xmx12G -Xms12G MergeSamFiles \
        INPUT=~{sep=" I="input_bams} \
        OUTPUT=merged.bam \
        SORT_ORDER=coordinate \
        ASSUME_SORTED=true \
        VALIDATION_STRINGENCY=LENIENT \
        MAX_RECORDS_IN_RAM=150000
    >>>
    output{
        File output_bam="merged.bam"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.6'
        singularity: '~{singularity_dir}/alignment_v0.0.6.sif'
    }
}

