version 1.0

task SplitBam{
    input{
        File bam
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 24
    }
    command<<<
        bam_utils split_bam_by_barcode --infile ~{bam} --outdir tempdir
    >>>
    output{
        Array[File] cell_bams = glob('tempdir/*bam')
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

task ExtractSeqData{
    input{
        File bam
        File? bai
        File snp_positions
        Array[String] chromosomes
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 24
    }
    command<<<
        if [[ -z "~{bai}" ]]; then
            samtools index ~{bam}
        fi

        cellid=$(basename ~{bam})
        cellid="${cellid%.*}"

        haplotype_utils extract_seqdata --bam ~{bam} \
        --snp_positions ~{snp_positions} \
        --output output.h5 \
        --tempdir seqdata_temp \
        --chromosomes ~{sep=" "chromosomes} \
        --cell_id $cellid
    >>>
    output{
        File seqdata = "output.h5"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}



task ExtractChromosomeSeqData{
    input{
        File bam
        File bai
        File snp_positions
        String chromosome
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 24
    }
    command<<<
        haplotype_utils extract_chromosome_seqdata --bam ~{bam} \
        --snp_positions ~{snp_positions} \
        --output output.h5 \
        --chromosome ~{chromosome}
    >>>
    output{
        File seqdata = "output.h5"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task InferSnpGenotypeFromNormal{
    input{
        File seqdata
        String chromosome
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 24
    }
    command<<<
    haplotype_utils infer_snp_genotype_from_normal \
    --seqdata ~{seqdata} \
    --output snp_genotype.tsv \
    --chromosome  ~{chromosome}
    >>>
    output{
        File snp_genotype = "snp_genotype.tsv"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}



task InferHaps{
    input{
        File snp_genotype
        File thousand_genomes_impute_tar
        String chromosome
        String genetic_map_filename_template
        String haplotypes_filename_template
        String legend_filename_template
        String sample_filename
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 24
    }
    command<<<
        haplotype_utils infer_haps \
        --snp_genotype ~{snp_genotype} \
        --thousand_genomes_impute_tar ~{thousand_genomes_impute_tar} \
        --output haplotypes.tsv \
        --chromosome ~{chromosome} \
        --tempdir tempdir \
        --genetic_map_filename_template ~{genetic_map_filename_template} \
        --haplotypes_filename_template ~{haplotypes_filename_template} \
        --legend_filename_template ~{legend_filename_template} \
        --sample_filename ~{sample_filename}
    >>>
    output{
        File haplotypes = "haplotypes.tsv"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task MergeSeqData{
    input{
        Array[File] infiles
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 24
    }
    command<<<
        haplotype_utils merge_seqdata --inputs ~{sep=" "infiles} --output output.h5
    >>>
    output{
        File merged_haps = "output.h5"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}



task MergeHaps{
    input{
        Array[File] infiles
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 24
    }
    command<<<
        haplotype_utils merge_haps --inputs ~{sep=" "infiles} --output output.tsv
    >>>
    output{
        File merged_haps = "output.tsv"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task AnnotateHaps{
    input{
        File infile
        File thousand_genomes_snps
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 24
    }
    command<<<
        haplotype_utils annotate_haps --input ~{infile} \
        --thousand_genomes ~{thousand_genomes_snps} \
        --output annotated.csv.gz --tempdir tmpdir
    >>>
    output{
        File outfile = "annotated.csv.gz"
        File outfile_yaml = "annotated.csv.gz.yaml"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}



task CreateSegments{
    input{
        File reference_fai
        File gap_table
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 24
    }
    command<<<
        haplotype_utils create_segments \
        --reference_fai ~{reference_fai} \
        --gap_table ~{gap_table} \
        --output output.tsv
    >>>
    output{
        File segments = "output.tsv"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task ConvertHaplotypesCsvToTsv{
    input{
        File infile
        File infile_yaml
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 24
    }
    command<<<
        haplotype_utils convert_haplotypes_csv_to_tsv \
        --input ~{infile} \
        --output output.tsv
    >>>
    output{
        File outfile = "output.tsv"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}



task HaplotypeAlleleReadcount{
    input{
        File seqdata
        File segments
        File haplotypes
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 24
    }
    command<<<
        mkdir -p temp
        haplotype_utils haplotype_allele_readcount \
        --seqdata ~{seqdata} \
        --segments ~{segments} \
        --haplotypes ~{haplotypes} \
        --output allele_counts.csv.gz \
        --tempdir temp
    >>>
    output{
        File outfile = "allele_counts.csv.gz"
        File outfile_yaml = "allele_counts.csv.gz.yaml"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

task HaplotypesMetadata{
    input{
        Map[String, Array[File]] files
        Array[File] metadata_yaml_files
        Array[String] samples
        String? singularity_image
        String? docker_image
        Int? memory_gb = 7
        Int? walltime_hours = 8
    }
    command<<<
        haplotype_utils generate_metadata \
        --files ~{write_json(files)} \
        --metadata_yaml_files ~{sep=" "metadata_yaml_files} \
        --samples ~{sep=" "samples} \
        --metadata_output metadata.yaml
    >>>
    output{
        File metadata_output = "metadata.yaml"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}








