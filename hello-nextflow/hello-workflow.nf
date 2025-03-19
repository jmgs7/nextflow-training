#!/usr/bin/env nextflow
/*
 * Pipeline CLI parameters
 */
params.greeting = 'greetings.csv'
params.batch = 'test-batch'

workflow {

    // create a channel for inputs from a CSV file
    greeting_ch = Channel
        .fromPath(params.greeting)
        .splitCsv()
        .map { line -> line[0] }

    // emit a greeting
    sayHello(greeting_ch)

    // passes sayHello output to upperCase
    convertToUpper(sayHello.out)

    // passes convertToUpper output to collectGreetings
    collectGreetings(convertToUpper.out.collect(), params.batch)

    // optional view statements
    convertToUpper.out.view { greeting -> "Before collect: ${greeting}" }
    convertToUpper.out.collect().view { greeting -> "After collect: ${greeting}" }

    // report greetings count
    collectGreetings.out.count.view { num_greetings -> "There were ${num_greetings} greetings in this batch" }
}


/*
 * Use echo to print 'Hello World!' to a file
 */
process sayHello {

    publishDir 'results', mode: 'copy'

    input:
    val greeting

    output:
    path "${greeting}-output.txt"

    script:
    """
    echo '${greeting}' > '${greeting}-output.txt'
    """
}

/*
 * Use a text replacement tool to convert the greeting to uppercase
 */
process convertToUpper {

    publishDir 'results', mode: 'copy'

    input:
    path input_file

    output:
    path "UPPER-${input_file}"

    script:
    """
    cat '${input_file}' | tr [:lower:] [:upper:] > 'UPPER-${input_file}'
    """
}

/*
 * Collects uppercase greetings into a single file
 */
process collectGreetings {

    publishDir 'results', mode: 'copy'

    input:
    path input_files
    // Use path despite expeting multiple files, nextflow handle this
    val batch_name

    output:
    path "COLLECTED-${batch_name}-output.txt"
    val count_greetings, emit: count

    script:
    count_greetings = input_files.size()
    // vars have methods, check in documentation
    """
    cat ${input_files} > 'COLLECTED-${batch_name}-output.txt'
    """
}
