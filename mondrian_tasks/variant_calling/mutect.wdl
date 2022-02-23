version 1.0


task GetPileup{
    input{
        File input_bam
        File input_bai
        File reference
        File reference_fai
        File reference_dict
        File variants_for_contamination
        File variants_for_contamination_idx
        Array[String] intervals
        Int cores
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 96
    }
    command<<<
        mkdir outdir
        for interval in ~{sep=" "intervals}
            do
                echo "gatk GetPileupSummaries \
                -R ~{reference} -I ~{input_bam} \
                --interval-set-rule INTERSECTION -L ${interval} \
                -V ~{variants_for_contamination} \
                -L ~{variants_for_contamination} \
                -O outdir/${interval}_pileups.table">> commands.txt
            done
        parallel --jobs ~{cores} < commands.txt
    >>>
    output{
        Array[File] pileups = glob("outdir/*_pileups.table")
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: "~{cores}"
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}



task RunMutect{
    input{
        File normal_bam
        File normal_bai
        File tumour_bam
        File tumour_bai
        File reference
        File reference_fai
        File reference_dict
        File panel_of_normals
        File panel_of_normals_idx
        Array[String] intervals
        Int cores
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 96
    }
    command<<<
        mkdir raw_data

        gatk GetSampleName -R ~{reference} -I ~{tumour_bam} -O tumour_name.txt
        gatk GetSampleName -R ~{reference} -I ~{normal_bam} -O normal_name.txt

        for interval in ~{sep=" "intervals}
            do
                echo "gatk Mutect2 \
                -I ~{normal_bam} -normal `cat normal_name.txt` \
                -I ~{tumour_bam}  -tumor `cat tumour_name.txt` \
                -pon ~{panel_of_normals} \
                -R ~{reference} -O raw_data/${interval}.vcf.gz  --intervals ${interval} ">> commands.txt
            done
        parallel --jobs ~{cores} < commands.txt
    >>>
    output{
        Array[File] vcf_files = glob("raw_data/*.vcf.gz")
        Array[File] vcf_files_idx = glob("raw_data/*.vcf.gz.tbi")
        Array[File] stats_files = glob("raw_data/*.vcf.gz.stats")
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: "~{cores}"
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

task MergeVCFs {
    input {
      Array[File] vcf_files
      Array[File] vcf_files_tbi
      String? singularity_image
      String? docker_image
      Int? memory_gb = 12
      Int? walltime_hours = 8
    }
    command {
        set -e
        gatk --java-options "-Xmx4G" MergeVcfs -I ~{sep=' -I ' vcf_files} -O merged.vcf.gz
    }
    output {
        File merged_vcf = "merged.vcf.gz"
        File merged_vcf_tbi = "merged.vcf.gz.tbi"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}



task MergeStats {
    input {
      Array[File] stats
      String? singularity_image
      String? docker_image
      Int? memory_gb = 8
      Int? walltime_hours = 8
    }
    command {
        set -e
        gatk --java-options "-Xmx4G" MergeMutectStats \
            -stats ~{sep=" -stats " stats} -O merged.stats
    }
    output {
        File merged_stats = "merged.stats"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task MergePileupSummaries {
    input {
      Array[File] input_tables
      File reference_dict
      String? singularity_image
      String? docker_image
      Int? memory_gb = 8
      Int? walltime_hours = 8
    }

    command {
        set -e
        gatk GatherPileupSummaries \
        --sequence-dictionary ~{reference_dict} \
        -I ~{sep=' -I ' input_tables} \
        -O merged_pileup.tsv
    }
    output {
        File merged_table = "merged_pileup.tsv"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

task CalculateContamination {
    input {
      File tumour_pileups
      File normal_pileups
      String? singularity_image
      String? docker_image
      Int? memory_gb = 8
      Int? walltime_hours = 8
    }

    command {
        set -e
        gatk --java-options CalculateContamination \
        -I ~{tumour_pileups}  -matched  ~{normal_pileups} \
        -O contamination.table --tumor-segmentation segments.table
    }

    output {
        File contamination_table = "contamination.table"
        File maf_segments = "segments.table"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task Filter {
    input {
      File reference
      File reference_fai
      File reference_dict
      File unfiltered_vcf
      File unfiltered_vcf_tbi
      File mutect_stats
      File contamination_table
      File maf_segments
      String? singularity_image
      String? docker_image
      Int? memory_gb = 8
      Int? walltime_hours = 8
    }
    command {
        set -e
        gatk FilterMutectCalls -V ~{unfiltered_vcf} \
            -R ~{reference} \
            -O filtered.vcf.gz \
            -stats ~{mutect_stats} \
            --contamination-table ~{contamination_table} \
            --tumor-segmentation ~{maf_segments} \
            --filtering-stats filtering.stats
    }
    output {
        File filtered_vcf = "filtered.vcf.gz"
        File filtered_vcf_tbi = "filtered.vcf.gz.tbi"
        File filtering_stats = "filtering.stats"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}






