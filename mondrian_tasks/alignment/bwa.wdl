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
        File metadata_yaml
        String cell_id
        String lane_id
        String flowcell_id
        String? singularity_dir
    }
    command {
        alignment_utils bwa_align --metadata_yaml ~{metadata_yaml} \
        --fastq1 ~{fastq1} --fastq2 ~{fastq2}  --reference ~{reference} \
        --output aligned.bam --cell_id ~{cell_id} --lane_id ~{lane_id} \
        --flowcell_id ~{flowcell_id}
    }
    output {
        File bam = "aligned.bam"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "8:00"
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.9'
        singularity: '~{singularity_dir}/alignment_v0.0.9.sif'
    }
}
