version 1.0

task RunVcf2Maf{
    input{
        File input_vcf
        File vep_ref
        String vep_fasta_suffix
        String ncbi_build
        String cache_version
        String species
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 24

    }
    command<<<
        mkdir vep_ref_dir
        tar -xvf ~{vep_ref} --directory vep_ref_dir

        if (file ~{input_vcf} | grep -q compressed ) ; then
             gzcat ~{input_vcf} > uncompressed.vcf
        else
            cat ~{input_vcf} > uncompressed.vcf
        fi

        rm -f uncompressed.vep.vcf

        vcf2maf uncompressed.vcf output.maf \
          vep_ref_dir/vep/~{vep_fasta_suffix} \
          vep_ref_dir/vep ~{ncbi_build} ~{cache_version} ~{species}
    >>>
    output{
        File output_maf = 'output.maf'
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task UpdateMafId{
    input{
        File input_maf
        String normal_id
        String tumour_id
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 8

    }
    command<<<
        variant_utils update_maf_ids --input ~{input_maf} --tumour_id ~{tumour_id} --normal_id ~{normal_id} --output updated_id.maf
    >>>
    output{
        File output_maf = 'updated_id.maf'
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

task UpdateMafCounts{
    input{
        File input_maf
        File input_counts
        String filename_prefix
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 8

    }
    command<<<
        variant_utils update_maf_counts --input ~{input_maf} --counts ~{input_counts} --output ~{filename_prefix}_updated_counts.maf
    >>>
    output{
        File output_maf = filename_prefix + '_updated_counts.maf'
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task MergeMafs{
    input{
        Array[File] input_mafs
        String filename_prefix
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 8
    }
    command<<<
        touch ~{filename_prefix}.maf
    >>>
    output{
        File output_maf = "~{filename_prefix}.maf"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}