#!/usr/bin/env nextflow
workflow {

    // declare an array of input variables
    greetings_array = 'greetings.csv'

    // Create a channel for inputs
    greetings_ch = Channel
        .fromPath(greetings_array)
        .view { greeting -> "Before splitting: ${greeting}" }
        .splitCsv()
        .view { greeting -> "After splitting: ${greeting}" }
        .map { item -> item[0] }
        .view { greeting -> "After mapping: ${greeting}" }
    // Flaten is a channel operator that iterates through a list of values
    // splitCsv is an operator that splits the contents of a csv file (each row will be an array)
    // View is a channel operator that allows to inspect the contect of a channel
    // {} is the operator closure and allow to execute code iteratively within a channel
    // map is a powerful operator that maps each item of an array to an operation
    // Variables are only used within the scope of the closure and assigned with "->"

    // emit a greeting
    sayHello(greetings_ch)
}

/*
 * Use echo to print 'Hello World!' to a file
 */
process sayHello {

    publishDir 'results', mode: 'copy'

    input:
    val greeting

    output:
    // A single quote is considered a string literal
    path "${greeting}-output.txt"

    script:
    // For variable embbedding between triple quotes we use single quotes
    """
    echo '${greeting}' > '${greeting}-output.txt'
    """
}
