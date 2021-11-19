#!/bin/bash

function kctx() {
    local KCONFIG="${HOME}/.kube/config"
    local KCTXDIR="${HOME}/.kube/kctxcfg"
    setup() {
        if ! command -v yq &> /dev/null ; then
            echo "yq must be installed." 1>&2
            return 1
        fi
        rm -f "${KCTXDIR}"/*
        mkdir -p "${KCTXDIR}"
        local COUNT
        COUNT="$(yq e '.contexts | length' "${KCONFIG}")"
        local N=0
        while [ "${N}" -lt "${COUNT}" ]  ; do
            local CTX
            CTX="$(yq e ".contexts[${N}].name" "${KCONFIG}")"
            local CLUSTER
            CLUSTER="$(yq e ".contexts[${N}].context.cluster" "${KCONFIG}")"
            local KUSER
            KUSER="$(yq e ".contexts[${N}].context.user" "${KCONFIG}")"
            local PROG
            PROG="del(.clusters[] | select(.name != \"${CLUSTER}\"))"
            PROG="${PROG} | del(.contexts[] | select(.name != \"${CTX}\"))"
            PROG="${PROG} | del(.users[] | select(.name != \"${KUSER}\"))"
            PROG="${PROG} | .current-context=\"${CTX}\""
            yq e "${PROG}" "${KCONFIG}" > "${KCTXDIR}/${CTX}"
            N=$((N + 1))
        done
    }

    set_context() {
        KUBECONFIG="${KCTXDIR}/$1"
        export KUBECONFIG
        unset POD_NAMESPACE
        PS1="\h:\W ($1) \u\$ "
    }

    case "$1" in
    "-h")
        echo "Usage: kctx CONTEXT -- switch to CONTEXT and update PS1 prompt"
        echo "       kctx --setup -- read ${HOME}/.kube/config and write contexts to ${KCTXDIR}"
        return 1
        ;;
    "--setup")
        setup
        ;;
    
    *)
        set_context "$1"
        ;;
    esac
}
