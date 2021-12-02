version 1.0

task RunVcf2Maf{
    input{
        File input_vcf
        File vep_ref
        String? singularity_dir
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
          vep_ref_dir/vep/homo_sapiens/99_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz \
          vep_ref_dir/vep/ExAC_nonTCGA.r0.3.1.sites.vep.vcf.gz \
          vep_ref_dir/vep
    >>>
    output{
        File output_maf = 'output.maf'
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "24:00"
        docker: 'quay.io/mondrianscwgs/variant:v0.0.8'
        singularity: '~{singularity_dir}/variant_v0.0.8.sif'
    }
}


task UpdateMafId{
    input{
        File input_maf
        String normal_id
        String tumour_id
        String? singularity_dir
    }
    command<<<
        variant_utils update_maf_ids --input ~{input_maf} --tumour_id ~{tumour_id} --normal_id ~{normal_id} --output updated_id.maf
    >>>
    output{
        File output_maf = 'updated_id.maf'
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "8:00"
        docker: 'quay.io/mondrianscwgs/variant:v0.0.8'
        singularity: '~{singularity_dir}/variant_v0.0.8.sif'
    }
}

task UpdateMafCounts{
    input{
        File input_maf
        File input_counts
        String filename_prefix
        String? singularity_dir
    }
    command<<<
        variant_utils update_maf_counts --input ~{input_maf} --counts ~{input_counts} --output ~{filename_prefix}_updated_counts.maf
    >>>
    output{
        File output_maf = filename_prefix + '_updated_counts.maf'
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "8:00"
        docker: 'quay.io/mondrianscwgs/variant:v0.0.8'
        singularity: '~{singularity_dir}/variant_v0.0.8.sif'
    }
}


task MergeMafs{
    input{
        Array[File] input_mafs
        String? singularity_dir
        String filename_prefix
    }
    command<<<
        touch ~{filename_prefix}.maf
    >>>
    output{
        File output_maf = "~{filename_prefix}.maf"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "8:00"
        docker: 'quay.io/mondrianscwgs/variant:v0.0.8'
        singularity: '~{singularity_dir}/variant_v0.0.8.sif'
    }
}