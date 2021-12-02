version 1.0


task runGridss{
    input{
        File normal_bam
        File tumour_bam
        Int num_threads
        File reference
        File reference_fa_fai
        File reference_fa_amb
        File reference_fa_ann
        File reference_fa_bwt
        File reference_fa_pac
        File reference_fa_sa
        String? singularity_dir
        String filename_prefix
    }
    command{
        gridss.sh \
        --assembly assembly/assembly.bam \
        --reference ~{reference} \
        --output ~{filename_prefix}_gridss.vcf.gz \
        --threads ~{num_threads} \
        --workingdir workingdir \
        --jvmheap 30g \
        --steps All \
        --labels tumour,normal ~{tumour_bam} ~{normal_bam}
    }
    output{
        File output_vcf = "~{filename_prefix}_gridss.vcf.gz"
    }
    runtime{
        memory: "8 GB"
        cpu: num_threads
        walltime: "240:00"
        docker: 'quay.io/mondrianscwgs/breakpoint:v0.0.8'
        singularity: '~{singularity_dir}/breakpoint_v0.0.8.sif'
    }
}