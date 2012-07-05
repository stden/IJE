//
//
//  Copyright (c) 2006
//  Roman Timushev
//
//  Permission to use, copy, modify, distribute and sell this software
//  and its documentation for any purpose is hereby granted without fee,
//  provided that the above copyright notice appear in all copies and
//  that both that copyright notice and this permission notice appear
//  in supporting documentation. Roman Timushev makes no representations
//  about the suitability of this software for any purpose.
//  It is provided "as is" without express or implied warranty.
//
//

#include "stdafx.h"

#include "..\launcher_lib\WinApiException.h"
#include "..\launcher_lib\Process.h"
#include "..\launcher_lib\Job.h"
#include "..\launcher_lib\JobResult.h"
#include "..\launcher_lib\RuntimeErrorMessages.h"
#include "..\launcher_lib\ConsoleWindow.h"
#include "..\launcher_lib\wide_stl.h"

using namespace std;
using namespace boost::program_options;

#ifdef _UNICODE
#define _command_line_parser wcommand_line_parser
#define _value wvalue
#else
#define _command_line_parser command_line_parser
#define _value value
#endif

volatile bool terminated = false;
bool show_status = false;
bool show_results = false;

const std::_string MESSAGE_ERROR_PARSING_COMMAND_LINE = _T("Error in command line: ");
const std::_string MESSAGE_DUPLICATE_OPTION = _T("duplicate option");

BOOL WINAPI CtrlHandler(DWORD)
{
    terminated = true;
    return TRUE;
}

bool parseOptions(int argc, _TCHAR* argv[], variables_map * vm)
{
    options_description general_options("General options");
    general_options.add_options()
        ("help,h","show help message")
        ("verbosity,v",_value<int>()->default_value(3),"verbosity level (0-3)");
    options_description restrict_options("Execution options");
    restrict_options.add_options()
        ("user,u",_value<_string>(),"username")
        ("password,p",_value<_string>(),"password")
        ("stdin,I",_value<_string>(),"redirect stdin to file")
        ("stdout,O",_value<_string>(),"redirect stdout to file")
        ("child,c",bool_switch(),"forbid child processes")
        ("desktop,d",bool_switch(),"use hidden desktop")
        ("time,t",_value<double>(),"time limit (sec)")
        ("memory,m",_value<double>(),"memory limit (MB)")
        ("idle,i",_value<double>(),"idleness limit (sec)");
    options_description hidden_options;
    hidden_options.add_options()
        ("command-line",_value<_string>());
    positional_options_description positional_options;
    positional_options.add("command-line",1);

    options_description all_options, visible_options;
    visible_options.add(general_options).add(restrict_options);
    all_options.add(visible_options).add(hidden_options);

    store(_command_line_parser(argc, argv).
        options(all_options).positional(positional_options).run(), *vm);
    notify(*vm);

    if (vm->count("verbosity")) {
        int verb = (*vm)["verbosity"].as<int>();
        if (verb<0 || verb>3) invalid_option_value(_T("")+verb);
        if (verb & 1) show_results = true;
        if (verb & 2) show_status = true;
    }
    if (vm->count("stdin") || vm->count("stdout")) {
        if (!vm->count("stdin") || !vm->count("stdout")) {
            throw error("\"stdin\" and \"stdout\" should be used simultaneously");
        }
    }
    if (vm->count("user") || vm->count("password")) {
        if (!vm->count("user") || !vm->count("password")) {
            throw error("\"user\" and \"password\" should be used simultaneously");
        }
    }

    if (vm->count("help") || !vm->count("command-line")) {
        cout << "RUN by Timushev Roman, alpha 0.2 FOR TEST ONLY\n\n"
            << "  run [options] application\n"
            << visible_options;
        return false;
    }
    return true;
}

int _tmain(int argc, _TCHAR* argv[])
{
    _CrtSetDbgFlag( _CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
    SetConsoleCtrlHandler(CtrlHandler,true);
    locale::global(locale(".866",locale::ctype));

    variables_map vm;

    // Parsing program options
    try {
        if (!parseOptions(argc,argv,&vm)) return 0;
    }
    catch(multiple_occurrences e) {
        _cerr << MESSAGE_ERROR_PARSING_COMMAND_LINE << MESSAGE_DUPLICATE_OPTION << endl;
        return 0;
    }
    catch(error e) {
        _cerr << MESSAGE_ERROR_PARSING_COMMAND_LINE << e.what() << endl;
        return 0;
    }

    // Execution
    try {
        //		_cout << PerformanceQuery::getPerformanceObjectIndexByName(_T("Page File Bytes Peak"));
        Job job;
        job.pocessNbRestriction(vm["child"].as<bool>());
        if (vm.count("time"))
            job.timeLimitRestriction(static_cast<int>(vm["time"].as<double>()*1000));
        if (vm.count("memory"))
            job.memoryLimitRestriction(static_cast<int>(vm["memory"].as<double>()*1024*1024));
        if (vm.count("idle"))
            job.idlenessLimitRestriction(static_cast<int>(vm["idle"].as<double>()*1000));
        job.applyRestrictions();

        Desktop desktop(!vm["desktop"].as<bool>());

        Process process(vm["command-line"].as<_string>());
        process.setDesktop(&desktop);
        if (vm.count("user")) {
            _string pwd = _T("");
            if (vm.count("password")) pwd = vm["password"].as<_string>();
            process.setCredentials(vm["user"].as<_string>(),pwd);
        }
        if (vm.count("stdin") && vm.count("stdout")) {
            process.redirect(vm["stdin"].as<_string>(),vm["stdout"].as<_string>());
        }
        process.load();
        job.assignMainProcess(process);
        process.resume();
        CAutoPtr<ConsoleWindow> wnd;
        if (show_status) {
            ConsoleWindow * pWnd = new ConsoleWindow(CRect(-28,0,-1,5));
            wnd.Attach(pWnd);
            wnd->show();
        }
        while (job.active()) {
            job.waitForEvent(30);
            if (show_status) {
                _stringstream msg;
                msg << dec << fixed << showpoint << setprecision(1);
                msg << _T("Time elapsed:  ") << setw(6) << job.infoElapsedTime() << _T("\n");
                msg << _T("Time used:     ") << setw(6) << job.infoCPUTime() << _T("\n");
                msg << _T("Memory used:   ") << setw(6) << job.infoMemoryUsage()/1024 << _T("Kb\n");
                wnd->setMessage(msg.str());
                wnd->redraw();
            }
            if (terminated) job.terminate();
        }
        if (show_status)
            wnd->hide();
        JobResult result = job.result();
        if (result.result() == JobResult::OK) {
            DWORD code = process.exitCode();
            if (code != 0) {
                result = JobResult(JobResult::RE, RuntimeErrorMessages::getFullMessage(code));
            }
        }
        if (show_results) {
            job.gatherInfo();
            _cout << _T("Exit code:     ") << setw(6) << result.result() << _T(' ') << result.info() << endl;
            _cout << dec << fixed << showpoint << setprecision(1);
            _cout << _T("Time elapsed:  ") << setw(6) << job.infoElapsedTime() << _T("\n");
            _cout << _T("Time used:     ") << setw(6) << job.infoCPUTime() << _T("\n");
            _cout << _T("Memory used:   ") << setw(6) << job.infoMemoryUsagePeak()/1024 << _T(" KB\n");
        }
        return result.result();
    }
    catch (WinApiException e) {
        _cerr << e.message();
    }
    catch (exception e) {
        _cerr << e.what();
    }
    catch (...) {
        _cerr << _T("Strange exception") << endl;
    }
    return 0;
}
