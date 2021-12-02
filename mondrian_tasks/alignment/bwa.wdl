version 1.0


task BwaMemPaired {
    input {
        File fastq1
        File fastq2
        File reference
        File reference_fa_fai
        File reference_fa_amb
        File reference_fa_ann
        File reference_fa_bwt
        File reference_fa_pac
        File reference_fa_sa
        String library_id
        String lane_id
        String sample_id
        String center
        String? singularity_dir
    }
    command {
        bwa mem \
        -R  $(echo "@RG\tID:~{sample_id}_~{library_id}_~{lane_id}\tSM:~{sample_id}\tLB:~{library_id}\tPL:ILLUMINA\tPU:~{lane_id}\tCN:~{center}") \
        -C -M  \
        ~{reference} \
        ~{fastq1} ~{fastq2} \
        | samtools view -bSh - > aligned.bam
    }
    output {
        File bam = "aligned.bam"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "8:00"
        docker: 'us.gcr.io/nygc-dlp-s-c0c0/alignment:v0.0.8'
        singularity: '~{singularity_dir}/alignment_v0.0.8.sif'
    }
}
