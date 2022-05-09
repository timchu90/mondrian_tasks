version 1.0


task VcfReheaderId{
    input{
        File input_vcf
        File normal_bam
        File tumour_bam
        String vcf_tumour_id
        String vcf_normal_id
        String? singularity_image
        String? docker_image
        Int? memory_override
        Int? walltime_override
    }
    command<<<
        variant_utils vcf_reheader_id \
        --input ~{input_vcf} \
        --tumour ~{tumour_bam} \
        --normal ~{normal_bam} \
        --output output.vcf.gz \
        --vcf_tumour_id ~{vcf_tumour_id} \
        --vcf_normal_id ~{vcf_normal_id}
    >>>
    output{
        File output_file = "output.vcf.gz"
    }
    runtime{
        memory: "~{select_first([memory_override, 7])} GB"
        walltime: "~{select_first([walltime_override, 6])}:00"
        cpu: 1
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task GetRegionFromVcf{
    input{
        File input_vcf
        File input_tbi
        String interval
        String? singularity_image
        String? docker_image
        Int? memory_override
        Int? walltime_override
    }
    command<<<
        bcftools view ~{input_vcf} ~{interval} -o output.vcf
        bgzip output.vcf
        tabix output.vcf.gz
    >>>
    output{
        File output_vcf = "output.vcf.gz"
        File output_tbi = "output.vcf.gz.tbi"
    }
    runtime{
        memory: "~{select_first([memory_override, 7])} GB"
        walltime: "~{select_first([walltime_override, 6])}:00"
        cpu: 1
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task SplitVcf{
    input{
        File input_vcf
        String num_splits
        String? singularity_image
        String? docker_image
        Int? memory_override
        Int? walltime_override
    }
    command<<<
        vcf_utils split_vcf --infile ~{input_vcf} --num_splits ~{num_splits} --outdir temp_output

        ls temp_output|while read x; do bgzip temp_output/${x} && tabix temp_output/${x}.gz;done
    >>>
    output{
        Array[File] output_vcf = glob("temp_output/*.vcf.gz")
        Array[File] output_tbi = glob("temp_output/*.vcf.gz.tbi")
    }
    runtime{
        memory: "~{select_first([memory_override, 7])} GB"
        walltime: "~{select_first([walltime_override, 6])}:00"
        cpu: 1
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}