cat ${i} | paste - - | grep -v ^+ | sed 's/ //g' | sed 's/^@/>/' | tr '\t' '\n'
